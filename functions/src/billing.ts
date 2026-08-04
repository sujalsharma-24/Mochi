import { onRequest } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { db } from './admin.js';

// functions.config() is deprecated (shuts down entirely 2025-12-31) - defineSecret()/Secret
// Manager is the replacement, per project_mochi_trd's explicit call on this.
const webhookAuthSecret = defineSecret('REVENUECAT_WEBHOOK_SECRET');
const revenueCatApiKey = defineSecret('REVENUECAT_SECRET_API_KEY');

// Must match BillingRepository.kt's entitlementId and whatever the RevenueCat dashboard's
// entitlement is actually named.
const ENTITLEMENT_ID = 'premium';

interface RevenueCatSubscriberResponse {
  subscriber: {
    entitlements: Record<string, { expires_date: string | null }>;
  };
}

/**
 * Deliberately does NOT trust the webhook payload's own event type to decide entitlement state -
 * every event instead triggers a fresh lookup of the subscriber's authoritative current state via
 * RevenueCat's REST API (their own recommended pattern, since e.g. BILLING_ISSUE/CANCELLATION
 * don't necessarily mean "revoke access right now" - a canceled auto-renew still keeps access
 * until the paid period actually ends). This is the single highest-risk function in the whole
 * project: get it wrong and people either pay for nothing or get premium free.
 */
export const revenueCatWebhook = onRequest(
  { secrets: [webhookAuthSecret, revenueCatApiKey] },
  async (req, res) => {
    if (req.headers.authorization !== webhookAuthSecret.value()) {
      res.status(401).send('unauthorized');
      return;
    }

    const appUserId = req.body?.event?.app_user_id as string | undefined;
    if (!appUserId) {
      res.status(400).send('missing app_user_id');
      return;
    }

    const response = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`,
      { headers: { Authorization: `Bearer ${revenueCatApiKey.value()}` } }
    );

    if (!response.ok) {
      res.status(502).send('revenuecat lookup failed');
      return;
    }

    const body = (await response.json()) as RevenueCatSubscriberResponse;
    const entitlement = body.subscriber.entitlements[ENTITLEMENT_ID];
    const isActive =
      entitlement != null &&
      (entitlement.expires_date == null || new Date(entitlement.expires_date) > new Date());

    await db.collection('users').doc(appUserId).set(
      {
        subscriptionStatus: isActive ? 'active' : 'free',
        subscriptionExpiresAt: entitlement?.expires_date ?? null,
      },
      { merge: true }
    );

    res.status(200).send('ok');
  }
);
