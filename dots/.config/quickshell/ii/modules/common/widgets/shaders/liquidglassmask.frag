#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 glassSize;
    vec2 glassOrigin;
    vec2 backdropSize;
    vec4 tint;
    float spread;
    float zRadius;
    float refraction;
    float chroma;
    float edgeHighlight;
    float specular;
    float fresnel;
    float distortion;
    float saturation;
    float brightness;
    float bevelMode;
    float glassOpacity;
};

layout(binding = 1) uniform sampler2D backdrop;
layout(binding = 2) uniform sampler2D backdropBlur;
layout(binding = 3) uniform sampler2D shapeMask;
layout(binding = 4) uniform sampler2D shapeField;

float maskAt(vec2 px) {
    vec2 uv = px / glassSize;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
        return 0.0;
    return texture(shapeMask, uv).a;
}

float fieldAt(vec2 px) {
    vec2 uv = px / glassSize;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
        return 0.0;
    return texture(shapeField, uv).a;
}

// The field is the shape blurred by about 0.8 * sp, so its alpha is a smooth coverage
// ramp across the edge — half at the boundary — and reads back directly as distance.
// Gathering that ramp here instead would quantise the isoline into the sample pattern
// and stair-step every corner.
float depthAt(vec2 px, float sp) {
    return (fieldAt(px) - 0.5) * 2.0 * sp;
}

float bevelHeight(float d, float zR) {
    if (d <= 0.0)
        return 0.0;
    if (d >= zR)
        return zR;
    return sqrt(d * (2.0 * zR - d));
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 backdropUv(vec2 px) {
    vec2 inset = vec2(2.0) / backdropSize;
    return clamp(px / backdropSize, inset, vec2(1.0) - inset);
}

void main() {
    vec2 local = qt_TexCoord0 * glassSize;

    float shape = maskAt(local);
    float cov = fieldAt(local);

    float sp = max(spread, 1.0);
    float inside = (cov - 0.5) * 2.0 * sp;

    // Taken before the early-out: a quad straddling the boundary would have some of its
    // pixels gone by then, and the derivative there is exactly what the edge needs.
    float aa = max(fwidth(inside) * 0.5, 1e-4);

    if (shape <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    float edge = smoothstep(sp, 0.0, inside);

    // The sampled distance saturates at `sp`, so a deeper bevel than that would only
    // flatten the dome instead of rounding it further.
    float zR = clamp(zRadius, 1.0, sp);
    // The specular lobes go up to pow(...,120), so they resolve differences in the normal
    // of about a hundredth. A two-pixel stencil on a sampled field carries more noise than
    // that and breaks the highlight into dashes; reading the slope over a wider span costs
    // a little crispness in the bevel and none in the highlight.
    float e = 2.0;
    float hC = bevelHeight(inside, zR);
    float dR = depthAt(local + vec2(e, 0.0), sp);
    float dL = depthAt(local - vec2(e, 0.0), sp);
    float dD = depthAt(local + vec2(0.0, e), sp);
    float dU = depthAt(local - vec2(0.0, e), sp);
    vec2 hGrad = vec2(bevelHeight(dR, zR) - bevelHeight(dL, zR), bevelHeight(dD, zR) - bevelHeight(dU, zR)) / (2.0 * e);
    vec3 N = normalize(vec3(-hGrad, 1.0));

    // Points from the edge towards the thick part of the shape.
    vec2 dGrad = vec2(dR - dL, dD - dU) / (2.0 * e);
    float dLen = length(dGrad);
    vec2 inward = dLen > 1e-4 ? dGrad / dLen : vec2(0.0);

    float depth = smoothstep(0.0, zR, inside);

    float ior = 1.5;
    float refrPow = 1.0 - 1.0 / ior;
    float thickNorm = (hC * 2.0) / max(zR * 2.0, 1.0);
    vec2 refrPx;
    if (bevelMode < 0.5) {
        vec2 surface = hGrad * refrPow;
        refrPx = (surface * 2.0 + surface * thickNorm * 0.5) * refraction * 30.0;
    } else {
        // The rounded-rect shader bends light towards the middle of the panel. Here the
        // middle is the thick part of the stroke, so the lens follows the letter.
        refrPx = inward * (sp - inside) * refraction * depth * 0.35;
    }

    vec2 ns = local * 0.08;
    vec2 micro = (vec2(hash(ns), hash(ns + vec2(37.0))) - 0.5) * distortion * 4.0;

    vec2 caD = N.xy * (chroma * 36.0 * (edge * 0.7 + 0.3));
    vec2 base = glassOrigin + local + refrPx + micro;

    vec3 sharp = vec3(texture(backdrop, backdropUv(base + caD)).r, texture(backdrop, backdropUv(base)).g, texture(backdrop, backdropUv(base - caD)).b);
    vec3 blurred = vec3(texture(backdropBlur, backdropUv(base + caD)).r, texture(backdropBlur, backdropUv(base)).g, texture(backdropBlur, backdropUv(base - caD)).b);
    vec3 col = mix(sharp, blurred, 1.0 - edge * 0.15);

    col *= 1.0 + brightness;

    float lum = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(lum), col, 1.0 + saturation);

    col = mix(col, col * vec3(0.92, 0.95, 1.05), 0.5);
    col *= 1.0 + 0.06 * depth;
    col = mix(col, tint.a > 0.0 ? tint.rgb / tint.a : vec3(0.0), tint.a);

    float fres = pow(1.0 - abs(N.z), 4.0) * fresnel;

    vec3 V = vec3(0.0, 0.0, 1.0);
    vec3 H1 = normalize(normalize(vec3(0.4, 0.7, 1.0)) + V);
    float sp1 = pow(max(dot(N, H1), 0.0), 90.0);
    vec3 H2 = normalize(normalize(vec3(-0.3, -0.5, 1.0)) + V);
    float sp2 = pow(max(dot(N, H2), 0.0), 50.0) * 0.3;
    float spB = pow(max(dot(N, normalize(vec3(0.1, 0.3, 1.0))), 0.0), 6.0) * 0.1;
    vec3 H4 = normalize(normalize(vec3(0.0, 0.9, 0.4)) + V);
    float sp4 = pow(max(dot(N, H4), 0.0), 120.0) * 0.6;
    float totalSpec = (sp1 + sp2 + spB + sp4) * specular;

    float borderWidth = 1.5;
    float innerStroke = smoothstep(0.0, borderWidth, inside) * (1.0 - smoothstep(borderWidth, borderWidth + 1.0, inside));
    innerStroke *= 0.4 + 0.6 * (0.5 + 0.5 * (-(local.y - glassSize.y * 0.5) / max(glassSize.y * 0.5, 1.0)));

    float rim = edge * edgeHighlight * 0.22;
    float innerGlow = smoothstep(5.0, 0.0, inside) * edgeHighlight * 0.15;
    float envRefl = (N.y * 0.5 + 0.5) * fres * 0.08;

    // On a panel the same highlight strength spreads over a wide surface and reads as a
    // sheen. A letter gives it a few pixels of a narrow bevel, where pure white blows out,
    // so the highlight carries the colour of the glass it sits on.
    vec3 hi = mix(vec3(1.0), col, 0.35);

    col += hi * totalSpec;
    col += hi * (rim + innerGlow);
    col += hi * (innerStroke * edgeHighlight * 0.55);
    col += vec3(envRefl);
    col = mix(col, hi, fres * 0.2);

    // The field cuts convex corners and fills concave ones. Taking whichever of the two
    // covers less keeps the rounding on the outside corners and leaves the notches where
    // two edges meet from within as sharp as the letterform drew them.
    float a = min(shape, smoothstep(-aa, aa, inside)) * glassOpacity * qt_Opacity;
    fragColor = vec4(col * a, a);
}
