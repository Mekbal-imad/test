const mongoose = require("mongoose");
const dotenv = require("dotenv");

async function connectToDB(){
try{
    await mongoose.connect(process.env.MONGO_URL);
    console.log("Connected to DB");
}catch(err){
    console.log(err);
}
}
module.exports = connectToDB ;