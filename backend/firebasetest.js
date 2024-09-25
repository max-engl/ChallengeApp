const express = require('express');
const app = express();
const googleStorage = require('@google-cloud/storage');
const serviceAccount = require("./helpmeapp-70d40-4f6fcdf96370.json");

const admin = require("firebase-admin");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: "gs://helpmeapp-70d40.appspot.com"
});

const bucket = admin.storage().bucket();

async function uploadFile(filePath) {
    try {
        // Upload the video file
        const [file] = await bucket.upload(filePath, {
            // Set the destination file name
            destination: filePath.split('/').pop(),
            // Make the file publicly accessible
            public: true
        });

        // Get the public URL
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${file.name}`;
        console.log('File uploaded successfully:', publicUrl);


    } catch (error) {
        console.error('Error uploading file:', error);
    }
}
uploadFile("./testVideo2.mp4");
