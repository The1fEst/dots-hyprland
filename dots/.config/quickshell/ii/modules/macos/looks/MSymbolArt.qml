pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var catalogue: ({})

    readonly property string folder: Quickshell.shellPath("assets/sfsymbols")

    function aspectOf(symbol: string): real {
        return root.catalogue[symbol]?.aspect ?? 1;
    }

    function largestFitting(symbol: string, pixelWidth: real, pixelHeight: real): var {
        const sizes = root.catalogue[symbol]?.sizes;
        if (!sizes)
            return null;
        let fit = null;
        for (const size of sizes) {
            if (size[0] > pixelWidth || size[1] > pixelHeight)
                continue;
            if (!fit || size[0] * size[1] > fit[0] * fit[1])
                fit = size;
        }
        return fit ?? sizes[0];
    }

    function artFor(symbol: string, pixelWidth: real, pixelHeight: real): url {
        const fit = root.largestFitting(symbol, pixelWidth, pixelHeight);
        return fit ? `${root.folder}/${symbol}/${fit[0]}x${fit[1]}.png` : "";
    }

    FileView {
        id: manifest
        path: `${root.folder}/manifest.json`
        blockLoading: true
        watchChanges: true
        onFileChanged: manifest.reload()
        onLoaded: root.catalogue = JSON.parse(manifest.text())
        onLoadFailed: error => console.log("[MSymbolArt] no symbol manifest:", error)
    }
}
