const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendBulkNotifications = functions.https.onRequest(async (req, res) => {
    const { title, subtitle, type, dynamicId, uid } = req.body;
    const message = {
        notification: {
            title: title,
            body: subtitle,
        },
        android: {
            priority: 'high',

            data: {
                type: type,
                dynamicId: dynamicId,
                uid: uid,
            },
        },
        topic: 'all'
    };

    await admin.messaging().send(message);
    return res.status(200).send({ 'success': true });
});
