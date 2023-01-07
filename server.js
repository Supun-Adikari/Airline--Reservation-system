const express = require('express')
var apiController = require("./API/API");
var authController = require("./API/Auth");
var {RestoreSession} = require("./MODEL/Authentication");
const app = express()

const dotenv = require('dotenv');
dotenv.config();

app.use(express.urlencoded({extended: true}));
app.use(express.json())

RestoreSession();


app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "http://localhost:3000"); 
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
    res.header("Access-Control-Allow-Methods", "DELETE, PUT");
    next();
});

app.use('/', apiController)

app.use('/api',apiController);
app.use('/auth',authController);


//Set up EJS//udj
app.set('view engine', 'ejs')
app.use(express.static('public'))

const port = process.env.port 
app.listen(port, () => {
  console.log(`Example app listening on port http://localhost:${port}`)
})