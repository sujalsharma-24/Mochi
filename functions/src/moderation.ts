import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as tf from '@tensorflow/tfjs';
import * as nsfwjs from 'nsfwjs';
import jpeg from 'jpeg-js';
import { PNG } from 'pngjs';

/**
 * No Google Cloud Vision here on purpose - Sujal asked for a completely free/local alternative
 * with no paid API key. nsfwjs (MIT-licensed, github.com/infinitered/nsfwjs) runs the whole
 * classification locally in this function's own process using a small pretrained MobileNetV2
 * model - no per-image billing, no API key, no external account. The model weights (a few MB) load
 * once per cold start from nsfwjs's public model CDN, which is free and requires no credentials -
 * that's the only network call this makes, and it's cached for the life of the function instance
 * after the first request.
 *
 * `@tensorflow/tfjs` (pure JS/WASM, not `@tensorflow/tfjs-node`) is used deliberately: tfjs-node's
 * native bindings failed to compile on this Windows dev machine (no Visual Studio C++ build tools),
 * and the same native-compile step would be a real risk on Cloud Functions' build environment too.
 * jpeg-js/pngjs decode the uploaded image into raw pixels in pure JS for the same reason - no
 * native `canvas` dependency.
 */
let modelPromise: Promise<nsfwjs.NSFWJS> | null = null;
function getModel(): Promise<nsfwjs.NSFWJS> {
  if (!modelPromise) {
    modelPromise = nsfwjs.load();
  }
  return modelPromise;
}

/** Drops the alpha channel (nsfwjs's MobileNet input is RGB) and decodes whichever of the two
 * formats storage.rules actually allows theme images to be (jpeg-js also handles most images
 * Vision-adjacent multipart uploads produce; PNG is the other realistic case from a gallery pick). */
export function decodeToRgbTensor(bytes: Buffer, contentType: string): tf.Tensor3D {
  if (contentType.includes('png')) {
    const png = PNG.sync.read(bytes);
    return tf.tidy(() =>
      tf.tensor3d(new Int32Array(png.data), [png.height, png.width, 4]).slice([0, 0, 0], [-1, -1, 3])
    ) as tf.Tensor3D;
  }
  const decoded = jpeg.decode(bytes, { useTArray: true });
  return tf.tidy(() =>
    tf.tensor3d(new Int32Array(decoded.data), [decoded.height, decoded.width, 4]).slice(
      [0, 0, 0],
      [-1, -1, 3]
    )
  ) as tf.Tensor3D;
}

const FLAGGED_CLASSES = new Set(['Porn', 'Hentai']);
const REVIEW_THRESHOLD = 0.7;

export async function classifyImage(bytes: Buffer, contentType: string): Promise<'approved' | 'rejected'> {
  const model = await getModel();
  const tensor = decodeToRgbTensor(bytes, contentType);
  try {
    const predictions: nsfwjs.PredictionType[] = await model.classify(tensor);
    const flagged = predictions.some(
      (p: nsfwjs.PredictionType) => FLAGGED_CLASSES.has(p.className) && p.probability >= REVIEW_THRESHOLD
    );
    return flagged ? 'rejected' : 'approved';
  } finally {
    tensor.dispose();
  }
}

/**
 * Gallery-uploaded theme backgrounds must be moderated before appearing anywhere public (project
 * constraint - see project_mochi_constraints.md's UGC moderation section). Every feed query in
 * ThemeRepository.kt filters on moderationStatus == 'approved', so a theme just sits invisible
 * ("pending", CreateRepository's default) until this runs - no separate "hide" step needed on the
 * reject path, staying rejected is enough.
 */
export const onThemeCreated = onDocumentCreated('themes/{themeId}', async (event) => {
  const snap = event.data;
  if (!snap) return;
  const theme = snap.data();
  const imageUrl = theme.previewImageUrl as string | undefined;

  if (!imageUrl) {
    // Solid color / gradient background, no uploaded image - nothing to moderate.
    await snap.ref.update({ moderationStatus: 'approved' });
    return;
  }

  const response = await fetch(imageUrl);
  if (!response.ok) {
    // Can't fetch the image (deleted/broken URL) - leave it pending for manual review rather than
    // guessing either way.
    return;
  }
  const contentType = response.headers.get('content-type') ?? 'image/jpeg';
  const bytes = Buffer.from(await response.arrayBuffer());

  const moderationStatus = await classifyImage(bytes, contentType);
  await snap.ref.update({ moderationStatus });
});
