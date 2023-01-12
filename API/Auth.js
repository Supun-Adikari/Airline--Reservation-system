var express = require('express');
var router = express.Router();

const {ResponseHandler} = require("../Controller/ResponseController");
const Method = require("../Controller/method");

const {login,register,adminLogin} = require("../Model/Authentication");
const { application } = require('express');



router.post('/login',async function(req, res){
    console.log("login");
    var method = new Method(req,res);
    
    var log_status = await login(method);
    // const viewUser = getCurrentUser();
    console.log(log_status.status, log_status.user);
    if(log_status.status){
        res.render('user',{user:log_status});
    }
    else{
        console.log("login failed");
        res.redirect('../login');
    }    
});


router.post('/register',async function(req, res){
    console.log("register");
    var method = new Method(req,res);
    
    const status = await register(method);
    
    res.status(ResponseHandler(status)).send(status);

});

router.post('/adminHome',async function(req,res){
    console.log("admin login");

    var method = new Method(req,res);

    var log_status = await adminLogin(method);
    if(log_status.status){
        res.render('Admin/AdminHome');
    }
    else{
        console.log("admin login failed");
        res.redirect('../Admin/adminLogin');
    }
});

router.get('/adminLogin',async function(req, res){
    res.render('Admin/adminLogin');
});

module.exports = router;