const express = require('express')
var apiController = require("./API/API");
var authController = require("./API/Auth");
var {RestoreSession} = require("./MODEL/Authentication");
const app = express()
const dotenv = require('dotenv');
const axios = require('axios');
dotenv.config();

const port = process.env.port 

app.use(express.urlencoded({extended: true}));
app.use(express.json())

RestoreSession();


app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", `http://localhost:${port}`); 
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
    res.header("Access-Control-Allow-Methods", "DELETE, PUT,GET,POST");
    next();
});

app.use('/', apiController)

app.use('/api',apiController);
app.use('/auth',authController);

app.use('/admin',apiController);
// app.use(require('./API'));



//Set up EJS//udj
app.set('view engine', 'ejs')
app.use(express.static('public'))

app.listen(port, () => {
  console.log(`Example app listening on port http://localhost:${port}`)
})