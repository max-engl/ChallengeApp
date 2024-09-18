const express = require('express');
const router = express.Router();

const upload = multer({ storage });

router.get('/', videoController.getAllVideos);


module.exports = router;
