// inspect-firestore.js
// Usage (PowerShell):
// $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccount.json"; node tools\inspect-firestore.js

const admin = require('firebase-admin');

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error('Set GOOGLE_APPLICATION_CREDENTIALS to the service account JSON path.');
  process.exit(1);
}

admin.initializeApp();
const db = admin.firestore();

(async () => {
  const app = admin.app();
  const projectId = (app.options && app.options.projectId) || process.env.GCLOUD_PROJECT || null;
  console.log(`Using projectId: ${projectId || '<unknown>'}`);

  try {
    const collections = await db.listCollections();
    if (!collections || collections.length === 0) {
      console.log('No top-level collections found.');
      return;
    }

    for (const col of collections) {
      try {
        const snapshot = await col.get();
        console.log(`Collection '${col.id}' — documents: ${snapshot.size}`);
      } catch (err) {
        console.error(`Failed to read collection ${col.id}: ${err.message}`);
      }
    }
  } catch (err) {
    console.error('Error listing collections:', err.message);
    process.exit(1);
  }
})();
