const express = require("express");
const multer = require("multer");
const videoController = require("../controllers/videoController");
const path = require("path");
const router = express.Router();

// Set up multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/videos");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const fs = require("fs");
router.post("/like", videoController.likeVideo)
router.post("/dislike", videoController.dislikeVideo)
router.get("/video/:index", videoController.getVideoWithIndex);
router.get("/videoData/:index", videoController.getVideoDataIndex);
router.get("/getAll", videoController.getAllVideos);

const upload = multer({ storage });

// Route to list all videos
router.get("/", videoController.getAllVideos);

// Route to upload a video
router.post("/upload", upload.single("video"), videoController.uploadVideo);

router.get("/delete", videoController.deleteAllVideos);

module.exports = router;
