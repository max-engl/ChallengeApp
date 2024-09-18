const path = require('path');
const fs = require('fs');
const Video = require('../models/videoModel');

// List all videos
exports.getAllVideos = async (req, res) => {
    try {
        const videos = await Video.find();
        res.json(videos);
    } catch (error) {
        res.status(500).json({ msg: 'Error fetching videos' });
    }
};


exports.uploadVideo = async (req, res) => {
    try {
        const newVideo = new Video({
            title: req.body.title,
            videoUrl: `/uploads/videos/${req.file.filename}`,
        });
        await newVideo.save();
        res.status(201).json(newVideo);
    } catch (error) {
        res.status(500).json({ msg: 'Error uploading video' });
    }
};

exports.getVideoWithIndex = async (req, res) => {
    try {
        let videoIndex = parseInt(req.params.index, 10);
        const totalVideos = await Video.countDocuments();

        if (totalVideos === 0) {
            console.log("No videos available.");
            return res.status(405).send('No videos available.');
        }

        videoIndex = videoIndex % totalVideos;
        console.log(`Request received for video index: ${videoIndex}`);

        const video = await Video.find().skip(videoIndex).limit(1).exec();

        if (!video.length) {
            console.log("Video not found.");
            return res.status(404).send('Video not found.');
        }

        const videoUrl = video[0].videoUrl;
        const videoFilename = path.basename(videoUrl);
        const videoPath = path.resolve(__dirname, '../uploads/videos', videoFilename);

        console.log(`Serving video from path: ${videoPath}`);

        if (!fs.existsSync(videoPath)) {
            return res.status(404).send('Video file not found.');
        }

        const stat = fs.statSync(videoPath);
        const fileSize = stat.size;
        const range = req.headers.range;

        const CHUNK_SIZE = .5 * 1024 * 1024; // 0.5MB

        if (range) {
            const parts = range.replace(/bytes=/, "").split("-");
            const start = parseInt(parts[0], 10);
            const end = parts[1] ? parseInt(parts[1], 10) : Math.min(start + CHUNK_SIZE - 1, fileSize - 1);

            console.log(`Range request for bytes ${start}-${end}`);

            if (start >= fileSize) {
                res.status(416).send(`Requested range not satisfiable: ${start} >= ${fileSize}`);
                return;
            }

            const chunksize = end - start + 1;
            const file = fs.createReadStream(videoPath, { start, end });
            const head = {
                'Content-Range': `bytes ${start}-${end}/${fileSize}`,
                'Accept-Ranges': 'bytes',
                'Content-Length': chunksize,
                'Content-Type': 'video/mp4',
            };

            res.writeHead(206, head);
            file.pipe(res);
        } else {
            console.log(`Full video requested for ${videoPath}`);
            const head = {
                'Content-Length': fileSize,
                'Content-Type': 'video/mp4',
            };
            res.writeHead(200, head);
            fs.createReadStream(videoPath).pipe(res);
        }
    } catch (error) {
        console.error('Error fetching video:', error);
        res.status(500).json({ msg: 'Error fetching video' });
    }
};



// Delete all videos from the folder and clear the video collection
exports.deleteAllVideos = async (req, res) => {
    try {
        // Path to the videos directory
        const videosDir = path.resolve(__dirname, '../uploads/videos');

        // Read all files in the directory
        fs.readdir(videosDir, async (err, files) => {
            if (err) {
                return res.status(500).send('Unable to scan directory: ' + err);
            }

            // Filter only .mp4 files (assuming all videos are .mp4)
            const videoFiles = files.filter(file => file.endsWith('.mp4'));

            // Delete each file
            videoFiles.forEach(file => {
                const filePath = path.join(videosDir, file);
                fs.unlink(filePath, (err) => {
                    if (err) {
                        console.error('Error deleting file:', filePath, err);
                    }
                });
            });

            // Clear the video collection in the database
            await Video.deleteMany({});

            res.status(200).json({ msg: 'All videos deleted and collection cleared' });
        });
    } catch (error) {
        res.status(500).json({ msg: 'Error deleting videos' });
    }
};
