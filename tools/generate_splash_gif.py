"""Generate splash_animated_logo.gif from transparent logo PNG."""

from __future__ import annotations

import math
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Install Pillow: pip install Pillow")
    sys.exit(1)

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "images"

SOURCE_CANDIDATES = [
    ASSETS / "splash_logo.png",
    ROOT / "assets" / "splash_aminated_image-removebg-preview.png",
    ROOT / "assets" / "splash_aminated_image.jpeg",
]

OUTPUT_GIF = ASSETS / "splash_animated_logo.gif"
SIZE = 512
FRAMES = 68
DURATION_MS = 200  # 3.6s loop
CENTER_RADIUS_FRAC = 0.29
OUTER_RING_INNER_FRAC = 0.26
OUTER_RING_OUTER_FRAC = 0.50
INNER_RING_INNER_FRAC = 0.18
INNER_RING_OUTER_FRAC = 0.42


def find_source() -> Path:
    for path in SOURCE_CANDIDATES:
        if path.exists():
            return path
    raise FileNotFoundError(f"No source logo found. Tried: {SOURCE_CANDIDATES}")


def remove_dark_background(img: Image.Image, threshold: int = 35) -> Image.Image:
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if r <= threshold and g <= threshold and b <= threshold:
                pixels[x, y] = (0, 0, 0, 0)
    return img


def fit_square(img: Image.Image, size: int) -> Image.Image:
    img = img.convert("RGBA")
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    fitted = img.resize((size, size), Image.Resampling.LANCZOS)
    return Image.alpha_composite(canvas, fitted)


def circle_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    cx = cy = size // 2
    draw.ellipse((cx - radius, cy - radius, cx + radius, cy + radius), fill=255)
    return mask


def annulus_mask(size: int, inner_r: int, outer_r: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    cx = cy = size // 2
    draw.ellipse(
        (cx - outer_r, cy - outer_r, cx + outer_r, cy + outer_r), fill=255
    )
    draw.ellipse(
        (cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r), fill=0
    )
    return mask


def masked_copy(img: Image.Image, mask: Image.Image) -> Image.Image:
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    layer.paste(img, (0, 0), mask)
    return layer


def rotate_layer(layer: Image.Image, degrees: float) -> Image.Image:
    return layer.rotate(
        degrees,
        resample=Image.Resampling.BICUBIC,
        expand=False,
        center=(layer.width / 2, layer.height / 2),
    )


def rgba_frame_to_palette(frame: Image.Image) -> Image.Image:
    alpha = frame.split()[3]
    rgb = frame.convert("RGB")
    palette = rgb.quantize(colors=255, method=Image.Quantize.MEDIANCUT)
    mask = Image.eval(alpha, lambda a: 255 if a < 20 else 0)
    palette.paste(255, mask)
    return palette


def main() -> None:
    ASSETS.mkdir(parents=True, exist_ok=True)
    source = find_source()
    print(f"Source: {source}")

    base = remove_dark_background(fit_square(Image.open(source), SIZE))

    center = masked_copy(
        base,
        circle_mask(SIZE, int(SIZE * CENTER_RADIUS_FRAC)),
    )
    outer_band = masked_copy(
        base,
        annulus_mask(
            SIZE,
            int(SIZE * OUTER_RING_INNER_FRAC),
            int(SIZE * OUTER_RING_OUTER_FRAC),
        ),
    )
    inner_band = masked_copy(
        base,
        annulus_mask(
            SIZE,
            int(SIZE * INNER_RING_INNER_FRAC),
            int(SIZE * INNER_RING_OUTER_FRAC),
        ),
    )

    palette_frames: list[Image.Image] = []

    for i in range(FRAMES):
        progress = i / FRAMES
        angle = progress * 360.0

        frame = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        frame = Image.alpha_composite(frame, center)
        frame = Image.alpha_composite(frame, rotate_layer(outer_band, angle))
        frame = Image.alpha_composite(
            frame, rotate_layer(inner_band, -angle * 1.18)
        )
        palette_frames.append(rgba_frame_to_palette(frame))

    OUTPUT_GIF.parent.mkdir(parents=True, exist_ok=True)
    palette_frames[0].save(
        OUTPUT_GIF,
        save_all=True,
        append_images=palette_frames[1:],
        duration=DURATION_MS,
        loop=0,
        disposal=2,
        transparency=255,
        optimize=True,
    )
    print(f"Saved: {OUTPUT_GIF} ({FRAMES} frames, {FRAMES * DURATION_MS / 1000:.1f}s)")


if __name__ == "__main__":
    main()
