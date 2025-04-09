// Import Firebase Functions and Admin SDK
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Cloud Function to send bulk notifications
exports.sendBulkNotifications = functions.https.onRequest(async (req, res) => {
    // Extract data from the request body
    const { title, subtitle, type, dynamicId, uid } = req.body;

    // Create the notification message
    const message = {
        notification: {
            title: title, // Notification title
            body: subtitle, // Notification body
        },
        android: {
            priority: 'high', // Set high priority for Android devices
            data: {
                type: type, // Custom data: type
                dynamicId: dynamicId, // Custom data: dynamicId
                uid: uid, // Custom data: uid
            },
        },
        topic: 'all' // Send to all devices subscribed to the 'all' topic
    };

    // Send the notification
    await admin.messaging().send(message);

    // Respond with success
    return res.status(200).send({ 'success': true });
});
