import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { FieldValue } from 'firebase-admin/firestore';
import { randomInt, createHash } from 'node:crypto';
import { db, auth } from './admin.js';

// functions.config() is deprecated - defineSecret()/Secret Manager per project_mochi_trd's
// ADR-012. No Twilio Verify Service here: Twilio now gates Verify Service creation behind an
// account upgrade (adding a payment method) as an anti-fraud measure, which blocked testing before
// the client is ready to pay. This sends a plain SMS via Twilio's Messages API instead, using the
// free trial phone number, and does the code generation/expiry/attempt-limiting ourselves that
// Verify would otherwise have handled. Swapping to a real Verify Service later (once upgraded) only
// needs this file rewritten to call Verify's API again - the Android client and its callable names/
// payloads stay the same either way.
const twilioAccountSid = defineSecret('TWILIO_ACCOUNT_SID');
const twilioAuthToken = defineSecret('TWILIO_AUTH_TOKEN');
const twilioFromNumber = defineSecret('TWILIO_FROM_NUMBER');

const E164_PATTERN = /^\+[1-9]\d{7,14}$/;
const CODE_TTL_MS = 10 * 60 * 1000; // matches Twilio Verify's own default expiry
const RESEND_COOLDOWN_MS = 30 * 1000;
const MAX_ATTEMPTS = 5;

function validatePhoneNumber(raw: unknown): string {
  const phoneNumber = typeof raw === 'string' ? raw.trim() : '';
  if (!E164_PATTERN.test(phoneNumber)) {
    throw new HttpsError(
      'invalid-argument',
      'Phone number must be in E.164 format, e.g. +15551234567.'
    );
  }
  return phoneNumber;
}

// Never store the raw code, only a salted hash - same reason passwords aren't stored in plaintext.
function hashCode(phoneNumber: string, code: string): string {
  return createHash('sha256').update(`${phoneNumber}:${code}`).digest('hex');
}

function twilioAuthHeader(): string {
  const credentials = `${twilioAccountSid.value()}:${twilioAuthToken.value()}`;
  return 'Basic ' + Buffer.from(credentials).toString('base64');
}

function otpDocRef(phoneNumber: string) {
  return db.collection('otpRequests').doc(phoneNumber);
}

export const sendPhoneOtp = onCall(
  { secrets: [twilioAccountSid, twilioAuthToken, twilioFromNumber] },
  async (request) => {
    const phoneNumber = validatePhoneNumber(request.data?.phoneNumber);
    const docRef = otpDocRef(phoneNumber);

    const existing = await docRef.get();
    const lastSentAtMs: number = existing.data()?.lastSentAtMs ?? 0;
    if (Date.now() - lastSentAtMs < RESEND_COOLDOWN_MS) {
      throw new HttpsError('resource-exhausted', 'Please wait before requesting another code.');
    }

    const code = randomInt(0, 1_000_000).toString().padStart(6, '0');

    await docRef.set({
      codeHash: hashCode(phoneNumber, code),
      expiresAt: Date.now() + CODE_TTL_MS,
      attempts: 0,
      lastSentAtMs: Date.now(),
      createdAt: FieldValue.serverTimestamp(),
    });

    const response = await fetch(
      `https://api.twilio.com/2010-04-01/Accounts/${twilioAccountSid.value()}/Messages.json`,
      {
        method: 'POST',
        headers: {
          Authorization: twilioAuthHeader(),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          To: phoneNumber,
          From: twilioFromNumber.value(),
          Body: `Your Mochi verification code is ${code}. It expires in 10 minutes.`,
        }),
      }
    );

    if (!response.ok) {
      const body = (await response.json()) as { message?: string };
      throw new HttpsError('internal', body.message ?? 'Twilio could not send the code.');
    }

    return { success: true };
  }
);

/**
 * On a correct code, mints a Firebase custom token for a user keyed by phone number - creating the
 * Firebase Auth user record on first sign-in, the same "sign-in and sign-up are the same call"
 * pattern AuthRepository.kt already uses for Google. isNewUser drives whether the client calls
 * userRepository.createUserProfile, since a client-side custom-token sign-in never populates
 * AuthResult.additionalUserInfo the way a normal client-side provider sign-in does.
 */
export const verifyPhoneOtp = onCall(
  { secrets: [twilioAccountSid, twilioAuthToken, twilioFromNumber] },
  async (request) => {
    const phoneNumber = validatePhoneNumber(request.data?.phoneNumber);
    const code = typeof request.data?.code === 'string' ? request.data.code.trim() : '';
    if (!code) {
      throw new HttpsError('invalid-argument', 'Verification code is required.');
    }

    const docRef = otpDocRef(phoneNumber);
    const snap = await docRef.get();
    const data = snap.data();

    if (!data || data.expiresAt < Date.now()) {
      throw new HttpsError('invalid-argument', 'That code has expired - request a new one.');
    }
    if (data.attempts >= MAX_ATTEMPTS) {
      throw new HttpsError('resource-exhausted', 'Too many incorrect attempts - request a new code.');
    }
    if (data.codeHash !== hashCode(phoneNumber, code)) {
      await docRef.update({ attempts: FieldValue.increment(1) });
      throw new HttpsError('invalid-argument', 'That code is incorrect.');
    }

    await docRef.delete();

    let isNewUser = false;
    let userRecord;
    try {
      userRecord = await auth.getUserByPhoneNumber(phoneNumber);
    } catch {
      userRecord = await auth.createUser({ phoneNumber });
      isNewUser = true;
    }

    const token = await auth.createCustomToken(userRecord.uid);
    return { token, isNewUser };
  }
);
