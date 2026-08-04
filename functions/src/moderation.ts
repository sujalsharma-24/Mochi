import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { ImageAnnotatorClient } from '@google-cloud/vision';

const visionClient = new ImageAnnotatorClient();

// The client types this field as `Likelihood | "UNKNOWN" | "VERY_UNLIKELY" | ... | "VERY_LIKELY"`
// (proto3 JSON representation) rather than only the numeric enum, so compare against the string
// form directly instead of importing the enum.
const FLAGGED_LIKELIHOODS = new Set(['LIKELY', 'VERY_LIKELY']);

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

  const [result] = await visionClient.safeSearchDetection(imageUrl);
  const safeSearch = result.safeSearchAnnotation;
  const flagged = safeSearch
    ? [safeSearch.adult, safeSearch.violence, safeSearch.racy].some(
        (likelihood) => likelihood != null && FLAGGED_LIKELIHOODS.has(String(likelihood))
      )
    : false;

  await snap.ref.update({ moderationStatus: flagged ? 'rejected' : 'approved' });
});
