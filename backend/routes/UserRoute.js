const express = require("express");
const router = express.Router();

const controller = require("../controllers/userController");
const upload = require("../multer");

//router.get("/delete-all", controller.deleteAllUsers);
router.get("/profile-pic/:userName", controller.getProfilePicture);
router.get("/getAll", controller.getAllUsers);
router.post("/", controller.getUserData);

module.exports = router;
