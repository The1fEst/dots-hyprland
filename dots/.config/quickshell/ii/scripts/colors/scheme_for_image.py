#!/usr/bin/env python3
import sys
from PIL import Image, ImageChops, ImageStat

# Allowed scheme types
SCHEMES = [
    "scheme-content",
    "scheme-expressive",
    "scheme-fidelity",
    "scheme-fruit-salad",
    "scheme-monochrome",
    "scheme-neutral",
    "scheme-rainbow",
    "scheme-tonal-spot"
]

def image_colorfulness(image):
    # Based on Hasler and Süsstrunk's colorfulness metric
    (R, G, B) = image.split()
    rg = ImageChops.difference(R, G)
    # ImageChops.add(a, b, scale=2) is (a + b) / 2
    yb = ImageChops.difference(ImageChops.add(R, G, scale=2), B)
    rg_stat = ImageStat.Stat(rg)
    yb_stat = ImageStat.Stat(yb)
    std_rg, mean_rg = rg_stat.stddev[0], rg_stat.mean[0]
    std_yb, mean_yb = yb_stat.stddev[0], yb_stat.mean[0]
    colorfulness = (std_rg ** 2 + std_yb ** 2) ** 0.5 + (0.3 * (mean_rg ** 2 + mean_yb ** 2) ** 0.5)
    return colorfulness

# scheme-content respects the image's colors very well, but it might
# look too saturated, so we only use it for not very colorful images to be safe
def pick_scheme(colorfulness):
    if colorfulness < 40:
        return "scheme-neutral"
    else:
        return "scheme-tonal-spot"

def load_and_resize_image(img_path, max_dim=128):
    try:
        img = Image.open(img_path)
        img.load()
    except Exception:
        return None
    img = img.convert("RGB")
    w, h = img.size
    if max(h, w) > max_dim:
        scale = max_dim / max(h, w)
        img = img.resize((max(1, int(w * scale)), max(1, int(h * scale))), Image.LANCZOS)
    return img

def main():
    colorfulness_mode = False
    args = sys.argv[1:]
    if '--colorfulness' in args:
        colorfulness_mode = True
        args.remove('--colorfulness')
    if len(args) < 1:
        print("scheme-tonal-spot")
        sys.exit(1)
    img_path = args[0]
    img = load_and_resize_image(img_path)
    if img is None:
        print("scheme-tonal-spot")
        sys.exit(1)
    colorfulness = image_colorfulness(img)
    if colorfulness_mode:
        print(f"{colorfulness}")
    else:
        scheme = pick_scheme(colorfulness)
        print(scheme)

if __name__ == "__main__":
    main()
