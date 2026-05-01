const rateLimit = require("express-rate-limit");
const dotenv = require("dotenv");
const express = require("express");
const cors = require("cors");
const path = require("path");
const connectToDB = require("./config/db.js");
const {configCloudinary} = require("./config/cd.js");
const Routes = require("./router/apiRoute.js");
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,  // 15 minutes
    max: 100                    // 100 requests per IP
});

dotenv.config();

const app = express();
app.use(cors());
app.set('trust proxy', 1);
app.use(express.json());
app.use(limiter);

connectToDB();
configCloudinary();
app.use("/api" , Routes);
console.log("serverstarted") ;

app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: "Something went wrong" });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT , () =>{
    console.log("Server on port : " + PORT)
})




