const path = require("path");
const fs = require("fs");
const Video = require("../models/videoModel");
const ffmpeg = require("fluent-ffmpeg");

ffmpeg.setFfprobePath(
  "C:/Users/maxie/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-7.0.2-essentials_build/bin/ffprobe.exe"
);
ffmpeg.setFfmpegPath(
  "C:/Users/maxie/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-7.0.2-essentials_build/bin/ffmpeg.exe"
);

exports.getAllVideos = async (req, res) => {
  try {
    const videos = await Video.find();
    res.json(videos);
  } catch (error) {
    res.status(500).json({ msg: "Error fetching videos" });
  }
};

exports.uploadVideo = async (req, res) => {
  try {
    const originalVideoPath = req.file.path;
    console.log(req.body);
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
          .size("1080x1920")
          .output(outputVideoPath)
          .on("end", async () => {
            console.log("Video resized successfully");

            try {
              // Save the resized video information to the database
              const newVideo = new Video({
                title: req.body.title,
                videoUrl: `/uploads/videos/resized-${req.file.filename}`,
                userName: req.body.userName, // Ensure this is correctly passed
                description: req.body.description, // Ensure this is correctly passed
              });
              await newVideo.save();

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

              res.status(201).json(newVideo);
            } catch (error) {
              console.error("Error saving resized video:", error);
              res.status(500).json({ msg: "Error saving resized video" });
            }
          })
          .on("error", (err) => {
            console.error("Error resizing video:", err);
            res.status(500).json({ msg: "Error resizing video" });
          })
          .run();
      } else {
        try {
          // Save the video information to the database without resizing
          const newVideo = new Video({
            title: req.body.title,
            videoUrl: `/uploads/videos/${req.file.filename}`,
            userName: req.body.userName, // Ensure this is correctly passed
            description: req.body.description, // Ensure this is correctly passed
          });
          await newVideo.save();
          res.status(201).json(newVideo);
        } catch (error) {
          console.error("Error saving video:", error);
          res.status(500).json({ msg: "Error saving video" });
        }
      }
    });
  } catch (error) {
    console.error("Error uploading video:", error);
    res.status(500).json({ msg: "Error uploading video" });
  }
};

exports.getVideoDataIndex = async (req, res) => {
  try {
    let videoIndex = parseInt(req.params.index, 10);
    const totalVideos = await Video.countDocuments();

    if (totalVideos === 0) {
      console.log("No videos available.");
      return res.status(405).send("No videos available.");
    }

    videoIndex = videoIndex % totalVideos;

    // Fetch video metadata
    const video = await Video.find().skip(videoIndex).limit(1).exec();

    if (!video.length) {
      console.log("Video not found.");
      return res.status(404).send("Video not found.");
    }

    // Return video metadata as JSON
    const videoData = video[0];
    res.status(200).json({
      userName: videoData.userName,
      description: videoData.description,
      // Include any other relevant fields
    });
  } catch (error) {
    console.error("Error fetching data:", error);
    res.status(500).json({ msg: "Error fetching data" });
  }
};
exports.getVideoWithIndex = async (req, res) => {
  try {
    let videoIndex = parseInt(req.params.index, 10);
    const totalVideos = await Video.countDocuments();

    if (totalVideos === 0) {
      console.log("No videos available.");
      return res.status(405).send("No videos available.");
    }

    videoIndex = videoIndex % totalVideos;
    console.log(`Request received for video index: ${videoIndex}`);

    const video = await Video.find().skip(videoIndex).limit(1).exec();

    if (!video.length) {
      console.log("Video not found.");
      return res.status(404).send("Video not found.");
    }

    const videoUrl = video[0].videoUrl;
    const videoFilename = path.basename(videoUrl);
    const videoPath = path.resolve(
      __dirname,
      "../uploads/videos",
      videoFilename
    );

    console.log(`Serving video from path: ${videoPath}`);

    if (!fs.existsSync(videoPath)) {
      return res.status(404).send("Video file not found.");
    }

    const stat = fs.statSync(videoPath);
    const fileSize = stat.size;
    const range = req.headers.range;

    const CHUNK_SIZE = 0.5 * 1024 * 1024; // 0.5MB

    if (range) {
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1]
        ? parseInt(parts[1], 10)
        : Math.min(start + CHUNK_SIZE - 1, fileSize - 1);

      console.log(`Range request for bytes ${start}-${end}`);

      if (start >= fileSize) {
        res
          .status(416)
          .send(`Requested range not satisfiable: ${start} >= ${fileSize}`);
        return;
      }

      const chunksize = end - start + 1;
      const file = fs.createReadStream(videoPath, { start, end });
      const head = {
        "Content-Range": `bytes ${start}-${end}/${fileSize}`,
        "Accept-Ranges": "bytes",
        "Content-Length": chunksize,
        "Content-Type": "video/mp4",
      };

      res.writeHead(206, head);
      file.pipe(res);
    } else {
      console.log(`Full video requested for ${videoPath}`);
      const head = {
        "Content-Length": fileSize,
        "Content-Type": "video/mp4",
      };
      res.writeHead(200, head);
      fs.createReadStream(videoPath).pipe(res);
    }
  } catch (error) {
    console.error("Error fetching video:", error);
    res.status(500).json({ msg: "Error fetching video" });
  }
};

// Delete all videos from the folder and clear the video collection
exports.deleteAllVideos = async (req, res) => {
  try {
    const videosDir = path.resolve(__dirname, "../uploads/videos");

    fs.readdir(videosDir, async (err, files) => {
      if (err) {
        return res.status(500).send("Unable to scan directory: " + err);
      }

      const videoFiles = files.filter((file) => file.endsWith(".mp4"));

      videoFiles.forEach((file) => {
        const filePath = path.join(videosDir, file);
        fs.unlink(filePath, (err) => {
          if (err) {
            console.error("Error deleting file:", filePath, err);
          }
        });
      });

      await Video.deleteMany({}); // Ensure this is awaited

      res
        .status(200)
        .json({ msg: "All videos deleted and collection cleared" });
    });
  } catch (error) {
    res.status(500).json({ msg: "Error deleting videos" });
  }
};
