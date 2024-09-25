const { Storage } = require('@google-cloud/storage');
const path = require('path');
const fs = require('fs');
const ffmpeg = require('fluent-ffmpeg');
const Video = require('./../../models/videoModel'); // Import your Video model
const Challenge = require('./../../models/challengeModel'); // Import your Challenge model

// Firebase Admin initialization
const serviceAccount = require("./../../helpmeapp-70d40-4f6fcdf96370.json");
const admin = require("firebase-admin");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: "gs://helpmeapp-70d40.appspot.com" // Update with your actual bucket
});

const bucket = admin.storage().bucket(); // Use Firebase Admin's bucket instance

// Video upload handler
exports.uploadVideo = async (req, res) => {
    try {
        const originalVideoPath = req.file.path;
        const outputVideoPath = path.join(
            path.dirname(originalVideoPath),
            `resized-${req.file.filename}`
        );

        // Use ffmpeg to get video metadata (resolution)
        ffmpeg.ffprobe(originalVideoPath, async (err, metadata) => {
            if (err) {
                console.error("Error getting video metadata:", err);
                return res.status(500).json({ msg: "Error processing video metadata" });
            }

            const { width, height } = metadata.streams[0];
            console.log(`Original video resolution: ${width}x${height}`);

            // Check if the video resolution is greater than 1920x1080
            if (width > 1080 || height > 1920) {
                console.log("Resizing video to Full HD (1920x1080)");

                // Use ffmpeg to resize the video
                ffmpeg(originalVideoPath)
                    .outputOptions([
                        '-vf scale=1080:1920', // Resize to 1080x1920
                        '-preset fast',
                        '-movflags +faststart'
                    ])
                    .save(outputVideoPath)
                    .on("end", async () => {
                        console.log("Video resized successfully");

                        // Upload resized video to Google Cloud Storage
                        try {
                            await uploadToStorage(outputVideoPath, req.body.title, req.body.description, req.body.userToken, req.body.challengeId, res);

                            // After successful upload, delete the resized video from the local system
                            fs.unlink(outputVideoPath, (err) => {
                                if (err) {
                                    console.error("Error deleting resized video file:", err);
                                } else {
                                    console.log("Resized video file deleted successfully");
                                }
                            });

                        } catch (error) {
                            console.error("Error uploading resized video:", error);
                            res.status(500).json({ msg: "Error uploading resized video" });
                        }

                        // Attempt to delete the original video after a small delay
                        setTimeout(() => {
                            fs.unlink(originalVideoPath, (err) => {
                                if (err) {
                                    console.error("Error deleting original video file:", err);
                                } else {
                                    console.log("Original video file deleted successfully");
                                }
                            });
                        }, 1000); // 1 second delay
                    })
                    .on("error", (err) => {
                        console.error("Error resizing video:", err);
                        res.status(500).json({ msg: "Error resizing video" });
                    });
            } else {
                // If the video doesn't need resizing, upload directly
                try {
                    await uploadToStorage(originalVideoPath, req.body.title, req.body.description, req.body.userToken, req.body.challengeId, res);

                    // After successful upload, delete the original video from the local system
                    fs.unlink(originalVideoPath, (err) => {
                        if (err) {
                            console.error("Error deleting original video file:", err);
                        } else {
                            console.log("Original video file deleted successfully");
                        }
                    });

                } catch (error) {
                    console.error("Error uploading video:", error);
                    res.status(500).json({ msg: "Error uploading video" });
                }
            }
        });
    } catch (error) {
        console.error("Error uploading video:", error);
        res.status(500).json({ msg: "Error uploading video" });
    }
};

// Function to upload the video to Google Cloud Storage and save info to MongoDB
async function uploadToStorage(videoPath, title, description, userToken, challengeId, res) {
    const fileName = path.basename(videoPath);
    const file = bucket.file(`videos/${fileName}`); // Set the path in the bucket
    console.log("upload to storage");

    // Upload the video file
    await bucket.upload(videoPath, {
        destination: `videos/${fileName}`, // Destination in the bucket
        metadata: { contentType: 'video/mp4' }, // Adjust as necessary for your video type
        public: true
    });

    // Get public URL
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/videos/${fileName}`;
    console.log('Video uploaded successfully:', publicUrl);

    // Save video information to MongoDB
    const newVideo = new Video({
        title: title,
        videoUrl: publicUrl,
        userToken: userToken,
        description: description,
        likes: 0,
        dislikes: 0,
        challenge: challengeId,
    });

    await newVideo.save();
    await Challenge.findByIdAndUpdate(challengeId, {
        $inc: { videoCount: 1 },
    });

    res.status(201).json(newVideo);
}
