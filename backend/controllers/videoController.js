const path = require("path");
const fs = require("fs");
const Video = require("../models/videoModel");
const Like = require("../models/likeModel");
const User = require("../models/userModel");
const Dislike = require("../models/dislikeModel");
const Challenge = require("../models/challengeModel");
const ffmpeg = require("fluent-ffmpeg");

//ffmpeg.setFfprobePath(
//"C:/Users/maxie/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-7.0.2-essentials_build/bin/ffprobe.exe"
//);
//ffmpeg.setFfmpegPath(
//  "C:/Users/maxie/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-7.0.2-essentials_build/bin/ffmpeg.exe"
//);

exports.getAllVideos = async (req, res) => {
  try {
    const videos = await Video.find();
    res.json(videos);
  } catch (error) {
    res.status(500).json({ msg: "Error fetching videos" });
  }
};

exports.createChallenge = async (req, res) => {
  const { titel, description, userId } = req.body;

  try {
    // Validation: Check if the title length is less than 4
    if (titel.length < 4) {
      console.log("Title must have at least 4 characters");
      return res
        .status(400)
        .json({ msg: "Title must have at least 4 characters" });
    }

    // Create a new challenge object
    const newChallenge = new Challenge({ titel, description, userId });

    // Save the new challenge to the database
    await newChallenge.save();

    console.log("Challenge created successfully");
    return res
      .status(201)
      .json({ msg: "Challenge created!", challenge: newChallenge });
  } catch (error) {
    console.error("Something went wrong while creating challenge:", error);
    return res
      .status(500)
      .json({ msg: "Error creating challenge", error: error.message });
  }
};

exports.dislikeVideo = async (req, res) => {
  try {
    const { userId, videoId } = req.body;

    const existingLike = await Like.findOne({ userId, videoId });

    if (existingLike) {
      await Like.deleteOne({ userId, videoId });
      await Video.findByIdAndUpdate(videoId, { $inc: { likes: -1 } });
    }

    // Check for existing like
    const existingDislike = await Dislike.findOne({ userId, videoId });

    if (existingDislike) {
      // If a like exists, remove it and update the likes count
      await Dislike.deleteOne({ userId, videoId });
      await Video.findByIdAndUpdate(videoId, { $inc: { dislikes: -1 } });
      return res.json({ message: "Dislike removed successfully." });
    } else {
      // If no like exists, create a new like and update the likes count
      const newDislike = new Dislike({ userId, videoId });
      await newDislike.save();
      await Video.findByIdAndUpdate(videoId, { $inc: { dislikes: 1 } });
      return res.json({ message: "Video liked successfully." });
    }
  } catch (error) {
    console.error("Error handling like/unlike:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

exports.deleteAllChallenges = async (req, res) => {
  try {
    await Challenge.deleteMany({}); // Ensure this is awaited

    res
      .status(200)
      .json({ msg: "All challenges deleted and collection cleared" });
  } catch (error) {
    res.status(500).json({ msg: "Error deleting challenges" });
  }
};

exports.getAllChallenges = async (req, res) => {
  try {
    // Find all challenges in the database, only return _id, title, and description
    const challenges = await Challenge.find(
      {},
      "_id titel description videoCount"
    );

    // Send the challenges as a JSON response
    res.status(200).json(challenges);
  } catch (error) {
    console.error("Error fetching challenges:", error);
    res.status(500).json({ msg: "Error fetching challenges" });
  }
};

exports.likeVideo = async (req, res) => {
  try {
    const { userId, videoId } = req.body;

    const existingDislike = await Dislike.findOne({ userId, videoId });

    if (existingDislike) {
      await Dislike.deleteOne({ userId, videoId });
      await Video.findByIdAndUpdate(videoId, { $inc: { dislikes: -1 } });
    }

    // Check for existing like
    const existingLike = await Like.findOne({ userId, videoId });

    if (existingLike) {
      // If a like exists, remove it and update the likes count
      await Like.deleteOne({ userId, videoId });
      await Video.findByIdAndUpdate(videoId, { $inc: { likes: -1 } });
      return res.json({ message: "Like removed successfully." });
    } else {
      // If no like exists, create a new like and update the likes count
      const newLike = new Like({ userId, videoId });
      await newLike.save();
      await Video.findByIdAndUpdate(videoId, { $inc: { likes: 1 } });
      return res.json({ message: "Video liked successfully." });
    }
  } catch (error) {
    console.error("Error handling like/unlike:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};
exports.uploadVideo = async (req, res) => {
  try {
    const originalVideoPath = req.file.path;
    const outputVideoPath = path.join(
      path.dirname(originalVideoPath),
      `resized-${req.file.filename}`
    );
    console.log(req.body);
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
                userToken: req.body.userToken, // Ensure this is correctly passed
                description: req.body.description, // Ensure this is correctly passed
                likes: 0,
                dislikes: 0,
                challenge: req.body.challengeId,
              });
              await newVideo.save();
              await Challenge.findByIdAndUpdate(req.body.challengeId, {
                $inc: { videoCount: 1 },
              });
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
          const newVideo = new Video({
            title: req.body.title,
            videoUrl: `/uploads/videos/${req.file.filename}`,
            userToken: req.body.userToken, // Ensure this is correctly passed
            description: req.body.description, // Ensure this is correctly passed
            likes: 0,
            dislikes: 0,
            challenge: req.body.challengeId,
          });
          await newVideo.save();
          await Challenge.findByIdAndUpdate(req.body.challengeId, {
            $inc: { videoCount: 1 },
          });
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

async function userNameFromUserToken(token) {
  try {
    const userData = await User.findOne({ token });
    if (userData) {
      return userData.userName;
    } else {
      return null;
    }
  } catch (error) {
    console.error("Error fetching user data from token:", error);
    return null;
  }
}

async function challengeTitelFromChallengeId(_id) {
  try {
    const challengeData = await Challenge.findOne({ _id });
    if (challengeData) {
      return challengeData.titel;
    } else {
      return null;
    }
  } catch (error) {
    console.error("Error fetching user data from token:", error);
    return null;
  }
}

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

    const videoData = video[0];
    const token = videoData.userToken;

    // Fetch the username using the token
    const userName = await userNameFromUserToken(token);

    if (!userName) {
      console.log("User not found for the given token.");
      return res.status(404).send("User not found.");
    }

    // Return video metadata as JSON
    res.status(200).json({
      videoid: videoData._id.toString(),
      userName: userName,
      description: videoData.description,
      likes: videoData.likes,
      dislikes: videoData.dislikes,
      challenge: await challengeTitelFromChallengeId(videoData.challenge),
      // Include any other relevant fields
    });
  } catch (error) {
    console.error("Error fetching data:", error);
    res.status(500).json({ msg: "Error fetching data" });
  }
};


exports.getVideoDataIndexWithChallenge = async (req, res) => {
  try {
    let videoIndex = parseInt(req.params.index, 10);
    let challenge = req.params.challengeId;
    const totalVideos = await Video.countDocuments({ challenge });

    if (totalVideos === 0) {
      console.log("No videos available for this challenge.");
      return res.status(404).send("No videos available for this challenge.");
    }

    videoIndex = videoIndex % totalVideos;

    // Fetch video metadata
    const video = await Video.find({ challenge }).skip(videoIndex).limit(1).exec();

    if (!video.length) {
      console.log("Video not found.");
      return res.status(404).send("Video not found.");
    }

    const videoData = video[0];
    const token = videoData.userToken;

    // Fetch the username using the token
    const userName = await userNameFromUserToken(token);

    if (!userName) {
      console.log("User not found for the given token.");
      return res.status(404).send("User not found.");
    }

    // Return video metadata as JSON
    res.status(200).json({
      videoid: videoData._id.toString(),
      userName: userName,
      description: videoData.description,
      likes: videoData.likes,
      dislikes: videoData.dislikes,
      challenge: await challengeTitelFromChallengeId(videoData.challenge),
      // Include any other relevant fields
    });
  } catch (error) {
    console.error("Error fetching data:", error);
    res.status(500).json({ msg: "Error fetching data" });
  }
};

const cache = require("memory-cache"); // Simple memory cache

// Cache total video count for 5 minutes
const getCachedVideoCount = async () => {
  const cachedCount = cache.get("totalVideos");
  if (cachedCount !== null) {
    return cachedCount;
  }

  const totalVideos = await Video.countDocuments();
  cache.put("totalVideos", totalVideos, 300000); // Cache for 5 minutes
  return totalVideos;
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

    // Find video from the database
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

    if (!fs.existsSync(videoPath)) {
      return res.status(404).send("Video file not found.");
    }

    const stat = await fs.promises.stat(videoPath);
    const fileSize = stat.size;
    const range = req.headers.range;

    const CHUNK_SIZE = 2 * 1024 * 1024; // 2MB

    // Handle range request
    if (range) {
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1]
        ? parseInt(parts[1], 10)
        : Math.min(start + CHUNK_SIZE - 1, fileSize - 1);

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
      // If no range header, send the entire video file
      const head = {
        "Content-Length": fileSize,
        "Content-Type": "video/mp4",
      };
      res.writeHead(200, head);
      fs.createReadStream(videoPath).pipe(res);
    }
  } catch (error) {
    console.error("Error fetching video:", error);
    res.status(500).json({ msg: "Error fetching video", error: error.message });
  }
};


exports.getVideoWithIndexAndChallange = async (req, res) => {
  try {
    let videoIndex = parseInt(req.params.index, 10);
    let challenge = req.params.challengeId;

    const totalVideos = await Video.countDocuments({ challenge });

    if (totalVideos === 0) {
      console.log("No videos available for this challenge.");
      return res.status(404).send("No videos available for this challenge.");
    }

    // Handle cyclic indexing (if index exceeds total videos)
    videoIndex = videoIndex % totalVideos;

    // Find video for the specific challenge and at the specific index
    const video = await Video.find({ challenge })
      .skip(videoIndex)
      .limit(1)
      .exec();

    if (!video.length) {
      console.log("Video not found for this challenge.");
      return res.status(404).send("Video not found for this challenge.");
    }

    const videoUrl = video[0].videoUrl;
    const videoFilename = path.basename(videoUrl);
    const videoPath = path.resolve(__dirname, "../uploads/videos", videoFilename);

    if (!fs.existsSync(videoPath)) {
      return res.status(404).send("Video file not found.");
    }

    const stat = await fs.promises.stat(videoPath);
    const fileSize = stat.size;
    const range = req.headers.range;

    const CHUNK_SIZE = 2 * 1024 * 1024; // 2MB

    // Handle range request (partial content)
    if (range) {
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : Math.min(start + CHUNK_SIZE - 1, fileSize - 1);

      if (start >= fileSize) {
        return res.status(416).send(`Requested range not satisfiable: ${start} >= ${fileSize}`);
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
      // Serve the entire video if no range is specified
      const head = {
        "Content-Length": fileSize,
        "Content-Type": "video/mp4",
      };
      res.writeHead(200, head);
      fs.createReadStream(videoPath).pipe(res);
    }
  } catch (error) {
    console.error("Error fetching video:", error);
    res.status(500).json({ msg: "Error fetching video", error: error.message });
  }
};


exports.deleteAllVideos = async (req, res) => {
  try {
    const videosDir = path.resolve(__dirname, "../uploads/videos");

    // Read all video files in the directory
    fs.readdir(videosDir, async (err, files) => {
      if (err) {
        return res.status(500).send("Unable to scan directory: " + err);
      }

      // Filter out .mp4 files
      const videoFiles = files.filter((file) => file.endsWith(".mp4"));

      // Delete each video file from the file system
      videoFiles.forEach((file) => {
        const filePath = path.join(videosDir, file);
        fs.unlink(filePath, (err) => {
          if (err) {
            console.error("Error deleting file:", filePath, err);
          }
        });
      });

      // Delete all video documents from the database
      await Video.deleteMany({});

      // Set `videoCount` of all challenges to 0
      await Challenge.updateMany({}, { $set: { videoCount: 0 } });

      // Respond with success message
      res.status(200).json({ msg: "All videos deleted and challenge video counts reset to 0." });
    });
  } catch (error) {
    console.error("Error deleting videos:", error);
    res.status(500).json({ msg: "Error deleting videos" });
  }
};
