import QtQuick

// One axis of a separable Gaussian. Chain two, horizontal then vertical, where the blur
// has to stay smooth under a derivative — MultiEffect blurs through a pyramid of
// downscaled copies, and that pyramid's grid survives into the gradient.
ShaderEffect {
    id: root

    required property variant source
    required property real sigma

    property vector2d direction: Qt.vector2d(1, 0)

    readonly property vector2d texStep: Qt.vector2d(root.direction.x / Math.max(1, root.width), root.direction.y / Math.max(1, root.height))

    supportsAtlasTextures: false
    fragmentShader: Qt.resolvedUrl("shaders/gaussian.frag.qsb")
}
