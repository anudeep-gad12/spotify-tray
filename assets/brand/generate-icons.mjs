import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, "../..");
const require = createRequire(join(repoRoot, "site/package.json"));
const sharp = require("sharp");
const pngToIco = require("png-to-ico");

const brandDir = __dirname;
const logoSvgPath = join(brandDir, "logo-mark.svg");
const logoSimpleSvgPath = join(brandDir, "logo-mark-simple.svg");
const appIconDir = join(repoRoot, "SpotifyTray/Assets.xcassets/AppIcon.appiconset");
const logoMarkImageSetDir = join(repoRoot, "SpotifyTray/Assets.xcassets/LogoMark.imageset");
const sitePublicDir = join(repoRoot, "site/public");

const macIconSizes = [
  { filename: "icon_16x16.png", size: 16, simple: true },
  { filename: "icon_16x16@2x.png", size: 32, simple: true },
  { filename: "icon_32x32.png", size: 32, simple: true },
  { filename: "icon_32x32@2x.png", size: 64, simple: true },
  { filename: "icon_128x128.png", size: 128, simple: false },
  { filename: "icon_128x128@2x.png", size: 256, simple: false },
  { filename: "icon_256x256.png", size: 256, simple: false },
  { filename: "icon_256x256@2x.png", size: 512, simple: false },
  { filename: "icon_512x512.png", size: 512, simple: false },
  { filename: "icon_512x512@2x.png", size: 1024, simple: false },
];

async function renderPng(svgBuffer, size) {
  return sharp(svgBuffer, { density: Math.max(96, Math.ceil((size / 512) * 384)) })
    .resize(size, size, { fit: "contain", background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png()
    .toBuffer();
}

async function main() {
  const logoSvgBuffer = readFileSync(logoSvgPath);
  const logoSimpleSvgBuffer = readFileSync(logoSimpleSvgPath);

  mkdirSync(appIconDir, { recursive: true });
  mkdirSync(logoMarkImageSetDir, { recursive: true });
  mkdirSync(sitePublicDir, { recursive: true });

  console.log("Generating macOS app icons...");
  for (const { filename, size, simple } of macIconSizes) {
    const outputPath = join(appIconDir, filename);
    const source = simple ? logoSimpleSvgBuffer : logoSvgBuffer;
    const pngBuffer = await renderPng(source, size);
    writeFileSync(outputPath, pngBuffer);
    console.log(`  ${filename} (${size}x${size}${simple ? ", simple" : ""})`);
  }

  console.log("Generating site assets...");
  copyFileSync(logoSvgPath, join(logoMarkImageSetDir, "logo-mark.svg"));
  copyFileSync(logoSvgPath, join(sitePublicDir, "logo-mark.svg"));
  copyFileSync(logoSvgPath, join(sitePublicDir, "favicon.svg"));

  const favicon16 = await renderPng(logoSimpleSvgBuffer, 16);
  const favicon32 = await renderPng(logoSimpleSvgBuffer, 32);
  const favicon48 = await renderPng(logoSimpleSvgBuffer, 48);
  const faviconIco = await pngToIco([favicon16, favicon32, favicon48]);
  writeFileSync(join(sitePublicDir, "favicon.ico"), faviconIco);
  console.log("  favicon.ico");

  const appleTouchIcon = await renderPng(logoSvgBuffer, 180);
  writeFileSync(join(sitePublicDir, "apple-touch-icon.png"), appleTouchIcon);
  console.log("  apple-touch-icon.png (180x180)");

  console.log("  logo-mark.svg");
  console.log("  favicon.svg");
  console.log("Done.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
