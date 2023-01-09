var express = require('express');
var router = express.Router();

const {ResponseHandler} = require("../Controller/ResponseController");
const Method = require("../Controller/method");

const {login,register} = require("../Model/Authentication");




router.post('/login',async function(req, res){
    console.log("login");
    var method = new Method(req,res);
    
    var log_status = await login(method);
    // const viewUser = getCurrentUser();
    console.log(log_status.status);
    if(log_status.status){
        console.log("login1");
        res.render('user');
    }
    else{
        console.log("login failed");
        res.render('login');
    }    
});


router.post('/register',async function(req, res){
    console.log("register");
    var method = new Method(req,res);
    
    const status = await register(method);
    
    res.status(ResponseHandler(status)).send(status);

});


module.exports = router;