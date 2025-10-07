/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize admin if not already initialized
if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

exports.fixAdminUser = functions.https.onRequest(async (req, res) => {
  try {
    const adminUid = 'APduHk4yn8TL1W9oahqYI0w4efU2';
    
    // Complete user data
    const userData = {
      email: 'admin@mit.edu',
      firstName: 'Albert',
      lastName: 'Einstein',
      name: 'Albert Einstein',
      role: 'admin',
      department: 'Administration',
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    console.log('Fixing admin user document...');
    console.log('UID:', adminUid);

    // Update the user document in Firestore
    await db.collection('users').doc(adminUid).set(userData, { merge: true });
    
    console.log('✅ Admin user document has been successfully updated!');
    
    // Verify the update
    const updatedDoc = await db.collection('users').doc(adminUid).get();
    const result = {
      success: true,
      message: 'Admin user document updated successfully',
      uid: adminUid,
      data: updatedDoc.exists ? updatedDoc.data() : null
    };
    
    res.status(200).json(result);
    
  } catch (error) {
    console.error('❌ Error fixing admin user:', error);
    res.status(500).json({
      success: false,
      message: 'Error fixing admin user',
      error: error.message
    });
  }
});

exports.getAdminUser = functions.https.onRequest(async (req, res) => {
  try {
    const adminUid = 'APduHk4yn8TL1W9oahqYI0w4efU2';
    const doc = await db.collection('users').doc(adminUid).get();
    
    res.status(200).json({
      success: true,
      exists: doc.exists,
      data: doc.exists ? doc.data() : null
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
