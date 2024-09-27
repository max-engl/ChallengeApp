const path = require("path");
const fs = require("fs");
const Video = require("../models/videoModel");
const Like = require("../models/likeModel");
const User = require("../models/userModel");
const Dislike = require("../models/dislikeModel");
const Challenge = require("../models/challengeModel");
const ffmpeg = require("fluent-ffmpeg");
const uploadLogic = require("./logic/uploadLogic")
//ffmpeg.setFfprobePath(
//"C:/Users/maxie/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-7.0.2-essentials_build/bin/ffprobe.exe"
//);
//ffmpeg.setFfmpegPath(
//  "C:/Users/maxie/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-7.0.2-essentials_build/bin/ffmpeg.exe"
//);

exports.uploadVideo = async (req, res) => {
  console.log("trying to upload");
  uploadLogic.uploadVideo(req, res);
}

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
async function videoData(req, res, video) {
  const videoData = video[0];
  const token = videoData.userToken;

  // Fetch the username using the token
  const userName = await userNameFromUserToken(token);

  if (!userName) {
    console.log("User not found for the given token.");
    return res.status(404).send("User not found.");
  }
  const videoId = video[0]["_id"];
  const userId = req.body["userToken"];

  // Await the Like query to check if the like exists
  const like = await Like.findOne({ videoId, userId });

  var liked = false;
  if (like) {

    liked = true;

  }

  const dislike = await Dislike.findOne({ videoId, userId });

  var disliked = false;
  if (dislike) {

    disliked = true;

  }
  // Return video metadata as JSON
  res.status(200).json({
    videoid: videoData._id.toString(),
    userName: userName,
    description: videoData.description,
    likes: videoData.likes,
    dislikes: videoData.dislikes,
    challenge: await challengeTitelFromChallengeId(videoData.challenge),
    liked: liked,
    disliked: disliked,

  });
}
exports.getVideoDataIndex = async (req, res) => {
  try {
    let videoIndex = parseInt(req.body["index"], 10);
    const totalVideos = await Video.countDocuments();

    if (totalVideos === 0) {
      console.log("No videos available.");
      return res.status(405).send("No videos available.");
    }

    videoIndex = videoIndex % totalVideos;

    const video = await Video.find().skip(videoIndex).limit(1).exec();

    if (!video.length) {
      console.log("Video not found.");
      return res.status(404).send("Video not found.");
    }



    // Assuming videoData is a function that sends the video data
    videoData(req, res, video);

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
    videoData(req, res, video);
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
    return res.status(201).send(videoUrl);

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
      console.log("Video not found.");
      return res.status(404).send("Video not found.");
    }

    const videoUrl = video[0].videoUrl;
    return res.status(201).send(videoUrl);

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
