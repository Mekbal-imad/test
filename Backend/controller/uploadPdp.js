
const { cloudinary, configCloudinary } = require("../config/cd");

async function uploadPDP(req, res) {
    
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "No file uploaded"
            });
        }
        const result = await new Promise((resolve, reject) => {
            const stream = cloudinary.uploader.upload_stream(
                { folder: "pdp" },
                (error, result) => {
                    if (error) return reject(error);
                    resolve(result);
                }
            );
            stream.end(req.file.buffer);
        });
        return res.status(200).json({
            success: true,
            url: result.secure_url
        });
    } catch (err) {
        return res.status(500).json({
            success: false,
            message: err.message
        })
    }
}
module.exports = uploadPDP; 