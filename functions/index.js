const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const ALLOWED_MIME_TYPES = [
  'image/png', 'image/jpeg', 'image/webp',
  'application/pdf', 'text/plain',
  'text/x-python', 'text/x-dart', 'application/javascript',
];

const MAX_FILE_SIZE = 10 * 1024 * 1024;
const MAX_FILES_PER_SUBMISSION = 5;

const MAGIC_BYTES = {
  'image/png': [0x89, 0x50, 0x4E, 0x47],
  'image/jpeg': [0xFF, 0xD8, 0xFF],
  'image/webp': [0x52, 0x49, 0x46, 0x46],
  'application/pdf': [0x25, 0x50, 0x44, 0x46],
};

exports.validateUpload = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  const uid = context.auth.uid;

  const userDoc = await admin.firestore().doc(`users/${uid}`).get();
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('permission-denied', 'User not found');
  }

  const { mimeType, sizeBytes, fileBase64 } = data;
  if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
    throw new functions.https.HttpsError('invalid-argument', `MIME type not allowed: ${mimeType}`);
  }
  if (sizeBytes > MAX_FILE_SIZE) {
    throw new functions.https.HttpsError('invalid-argument', 'File too large');
  }

  if (MAGIC_BYTES[mimeType] && fileBase64) {
    const bytes = Buffer.from(fileBase64, 'base64');
    const expected = MAGIC_BYTES[mimeType];
    for (let i = 0; i < expected.length; i++) {
      if (bytes[i] !== expected[i]) {
        throw new functions.https.HttpsError('invalid-argument', 'File content does not match declared type');
      }
    }
  }

  return { ok: true, uid };
});

exports.getSignedUrl = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  const uid = context.auth.uid;
  const { storagePath } = data;

  const userDoc = await admin.firestore().doc(`users/${uid}`).get();
  const isAdmin = userDoc.exists && userDoc.data().role === 'admin';
  const isOwner = storagePath.startsWith(`submissions/${uid}/`);

  if (!isAdmin && !isOwner) {
    throw new functions.https.HttpsError('permission-denied', 'Access denied');
  }

  const bucket = admin.storage().bucket();
  const file = bucket.file(storagePath);
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 5 * 60 * 1000,
  });

  return { url };
});
