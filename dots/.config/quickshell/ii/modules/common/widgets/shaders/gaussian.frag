#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 texStep;
    float sigma;
};

layout(binding = 1) uniform sampler2D source;

const int TAPS = 16;

void main() {
    float s = max(sigma, 0.001);
    float d = 3.0 * s / float(TAPS);

    vec4 sum = texture(source, qt_TexCoord0);
    float wsum = 1.0;
    for (int i = 1; i <= TAPS; ++i) {
        float o = float(i) * d;
        float w = exp(-0.5 * o * o / (s * s));
        sum += w * (texture(source, qt_TexCoord0 + texStep * o) + texture(source, qt_TexCoord0 - texStep * o));
        wsum += 2.0 * w;
    }

    fragColor = sum / wsum * qt_Opacity;
}
