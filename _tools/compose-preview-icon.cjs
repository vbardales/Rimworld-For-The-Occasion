// Composites the cutout ModIcon onto Preview.png, at the owner's instruction (2026-09-29): a corner,
// tilted, bleeding off the side and bottom edges as if the icon were sliding out of frame.
// Corner picked by which is emptier (measured, not guessed): bottom-left averages 31/255, bottom-right
// 49/255 over a 260x260 sample, so bottom-left, tilt +15deg per the owner's left/right -> +15/-15 rule.
// Re-run by hand if Preview.png or the cutout changes; its output (Preview.png itself) is committed.
const sharp = require('C:/Users/nelim/AppData/Roaming/npm/node_modules/sharp');
const path = require('path');
const root = path.resolve(__dirname, '..');

(async () => {
  const previewPath = path.join(root, 'Mod/About/Preview.png');
  const cutoutPath = path.join(root, 'Art/ModIcon-cutout.png');
  const preview = sharp(previewPath);
  const { width: pw, height: ph } = await preview.metadata();

  const iconSize = 240;
  const tiltDeg = 15; // left corner -> +15deg, per the owner's rule
  const bleed = 40; // px of the icon's own bounding box allowed to run past the frame's edge

  const rotated = await sharp(cutoutPath)
    .resize(iconSize, iconSize)
    .rotate(tiltDeg, { background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png()
    .toBuffer();
  const { width: rw, height: rh } = await sharp(rotated).metadata();

  const left = -bleed;
  const top = ph - rh + bleed;

  const out = await sharp(previewPath)
    .composite([{ input: rotated, left, top }])
    .png()
    .toBuffer();
  const fs = require('fs');
  fs.writeFileSync(previewPath, out);

  console.log(`composited ${rw}x${rh} icon at (${left}, ${top}) onto ${pw}x${ph} preview`);
})();
