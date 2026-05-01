const cloudinary = require('cloudinary').v2;

function configCloudinary() {
    if (
        !process.env.CLOUDINARY_NAME ||
        !process.env.CLOUDINARY_KEY ||
        !process.env.CLOUDINARY_SECRET
    ) {
        throw new Error("Cloudinary environment variables missing");
    }

    cloudinary.config({
        cloud_name: process.env.CLOUDINARY_NAME,
        api_key: process.env.CLOUDINARY_KEY,
        api_secret: process.env.CLOUDINARY_SECRET
    });


}

module.exports = { cloudinary, configCloudinary }
