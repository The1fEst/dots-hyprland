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
    float radius;
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
    float cornerPower;
};

layout(binding = 1) uniform sampler2D backdrop;
layout(binding = 2) uniform sampler2D backdropBlur;

float rrSDF(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    if (min(q.x, q.y) < 0.0)
        return max(q.x, q.y) - r;
    float n = max(cornerPower, 2.0);
    return pow(pow(q.x, n) + pow(q.y, n), 1.0 / n) - r;
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
    vec2 halfSize = glassSize * 0.5;
    vec2 p = local - halfSize;
    float r = min(radius, min(halfSize.x, halfSize.y));
    float sdf = rrSDF(p, halfSize, r);

    float mask = 1.0 - smoothstep(-1.5, 0.5, sdf);
    if (mask <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    float maxD = min(halfSize.x, halfSize.y);
    float inside = -sdf;
    float edge = smoothstep(maxD * 0.35, 0.0, inside);

    float zR = max(zRadius, 1.0);
    float e = 2.0;
    float hC = bevelHeight(inside, zR);
    float hR = bevelHeight(-rrSDF(p + vec2(e, 0.0), halfSize, r), zR);
    float hL = bevelHeight(-rrSDF(p - vec2(e, 0.0), halfSize, r), zR);
    float hD = bevelHeight(-rrSDF(p + vec2(0.0, e), halfSize, r), zR);
    float hU = bevelHeight(-rrSDF(p - vec2(0.0, e), halfSize, r), zR);
    vec2 hGrad = vec2(hR - hL, hD - hU) / (2.0 * e);
    vec3 N = normalize(vec3(-hGrad, 1.0));

    float depth = smoothstep(0.0, zR, inside);

    float ior = 1.5;
    float refrPow = 1.0 - 1.0 / ior;
    float thickNorm = (hC * 2.0) / max(zR * 2.0, 1.0);
    vec2 refrPx;
    if (bevelMode < 0.5) {
        vec2 surface = hGrad * refrPow;
        refrPx = (surface * 2.0 + surface * thickNorm * 0.5) * refraction * 30.0;
        refrPx += (-p / max(halfSize, vec2(1.0))) * refraction * 4.0 * depth;
    } else {
        refrPx = -p * refraction * depth * 0.35;
    }

    vec2 ns = p * 0.08;
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
    float innerStroke = smoothstep(-borderWidth - 1.0, -borderWidth, sdf) * (1.0 - smoothstep(-1.0, 0.0, sdf));
    innerStroke *= 0.4 + 0.6 * (0.5 + 0.5 * (-p.y / halfSize.y));

    float rim = edge * edgeHighlight * 0.22;
    float innerGlow = smoothstep(5.0, 0.0, -sdf) * edgeHighlight * 0.15;
    float envRefl = (N.y * 0.5 + 0.5) * fres * 0.08;

    col += vec3(totalSpec);
    col += vec3(rim + innerGlow);
    col += vec3(innerStroke * edgeHighlight * 0.55);
    col += vec3(envRefl);
    col = mix(col, vec3(1.0), fres * 0.2);

    float a = mask * glassOpacity * qt_Opacity;
    fragColor = vec4(col * a, a);
}
