const path = require('path');
const fs = require('fs');

const ffmpeg = require('fluent-ffmpeg');
const Video = require('./../../models/videoModel'); // Your Video model
const Challenge = require('./../../models/challengeModel'); // Your Challenge model
const { Storage } = require('@google-cloud/storage');
// Firebase Admin initialization
const serviceAccount = require("./../../helpmeapp-70d40-4f6fcdf96370.json");
const admin = require("firebase-admin");


if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: "gs://helpmeapp-70d40.appspot.com" // Your Firebase bucket URL
    });
}


const bucket = admin.storage().bucket(); // Firebase Storage bucket instance

// Function to generate a thumbnail
function generateThumbnail(videoPath, outputDir, callback) {
    const baseName = path.basename(videoPath, path.extname(videoPath)); // Get the base name without extension
    const thumbnailFilename = `thumbnail-${baseName}.png`; // Create thumbnail filename

    ffmpeg(videoPath)
        .on('end', function () {
            console.log('Thumbnail generated successfully');
            callback(null, thumbnailFilename); // Return the generated filename
        })
        .on('error', function (err) {
            console.error('Error generating thumbnail:', err);
            callback(err);
        })
        .screenshots({
            count: 1, // Number of thumbnails
            folder: outputDir, // Save to this folder
            size: '480x720', // Thumbnail size
            filename: thumbnailFilename // Corrected filename
        });
}


// Main video upload handler
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

            // Check if the video resolution is greater than 1080x1920
            if (width > 1080 || height > 1920) {
                console.log("Resizing video to Full HD (1080x1920)");

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

                        // Upload resized video and thumbnail
                        await uploadToStorage(outputVideoPath, req.body.title, req.body.description, req.body.userToken, req.body.challengeId, res);

                        // Delete the resized video from local storage
                        fs.unlink(outputVideoPath, (err) => {
                            if (err) {
                                console.error("Error deleting resized video file:", err);
                            } else {
                                console.log("Resized video file deleted successfully");
                            }
                        });

                        // Attempt to delete the original video after a delay
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
                // If no resizing is needed, upload directly
                await uploadToStorage(originalVideoPath, req.body.title, req.body.description, req.body.userToken, req.body.challengeId, res);

                // Delete the original video from local storage
                fs.unlink(originalVideoPath, (err) => {
                    if (err) {
                        console.error("Error deleting original video file:", err);
                    } else {
                        console.log("Original video file deleted successfully");
                    }
                });
            }
        });
    } catch (error) {
        console.error("Error uploading video:", error);
        res.status(500).json({ msg: "Error uploading video" });
    }
};
async function uploadToStorage(videoPath, title, description, userToken, challengeId, res) {
    const fileName = path.basename(videoPath);
    const file = bucket.file(`videos/${fileName}`); // Video file destination in Firebase Storage

    // Directory for thumbnails
    const thumbnailDir = path.join(__dirname, '../../uploads/thumbnails');

    // Ensure 'uploads/thumbnails' directory exists
    if (!fs.existsSync(thumbnailDir)) {
        fs.mkdirSync(thumbnailDir, { recursive: true });
    }

    // Generate the thumbnail
    let thumbnailFilename;
    await new Promise((resolve, reject) => {
        generateThumbnail(videoPath, thumbnailDir, (err, generatedThumbnail) => {
            if (err) {
                console.error('Error generating thumbnail:', err);
                reject(err);
            } else {
                thumbnailFilename = generatedThumbnail; // Corrected thumbnail filename
                resolve();
            }
        });
    });

    // Upload the video to Firebase Storage
    await bucket.upload(videoPath, {
        destination: `videos/${fileName}`, // Destination in the bucket
        metadata: { contentType: 'video/mp4' }, // Adjust for video type
        public: true
    });

    const publicUrl = `https://storage.googleapis.com/${bucket.name}/videos/${fileName}`;
    console.log('Video uploaded successfully:', publicUrl);

    // Upload the generated thumbnail
    const thumbnailPath = path.join(thumbnailDir, thumbnailFilename); // Correct thumbnail path
    const thumbnailFile = bucket.file(`thumbnails/${thumbnailFilename}`);
    await bucket.upload(thumbnailPath, {
        destination: `thumbnails/${thumbnailFilename}`, // Destination in Firebase
        metadata: { contentType: 'image/png' },
        public: true
    });

    const thumbnailUrl = `https://storage.googleapis.com/${bucket.name}/thumbnails/${thumbnailFilename}`;
    console.log('Thumbnail uploaded successfully:', thumbnailUrl);

    // Save video and thumbnail info to MongoDB
    const newVideo = new Video({
        title: title,
        videoUrl: publicUrl,
        thumbnailUrl: thumbnailUrl, // Thumbnail URL saved
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
