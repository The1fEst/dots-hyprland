import QtQuick

ShaderEffect {
    id: root

    required property variant backdrop
    required property variant backdropBlur

    property color tint: "#00000000"
    property real radius: 20
    property real zRadius: 4
    property real refraction: 0.24
    property real chroma: 0
    property real edgeHighlight: 0
    property real specular: 0.21
    property real fresnel: 0.84
    property real distortion: 0.03
    property real saturation: 0
    property real brightness: 0
    property real bevelMode: 0
    property real glassOpacity: 1
    property real cornerPower: 4

    readonly property point glassOrigin: {
        root.width;
        root.height;
        root.backdrop.width;
        root.backdrop.height;
        const stop = root.backdrop.parent;
        if (stop) {
            stop.x;
            stop.y;
        }
        for (let node = root; node; node = node.parent) {
            node.x;
            node.y;
            if (node === stop)
                break;
        }
        return root.mapToItem(root.backdrop, 0, 0);
    }
    readonly property size glassSize: Qt.size(root.width, root.height)
    readonly property size backdropSize: Qt.size(Math.max(1, root.backdrop.width), Math.max(1, root.backdrop.height))

    supportsAtlasTextures: false
    fragmentShader: Qt.resolvedUrl("shaders/liquidglass.frag.qsb")
}
