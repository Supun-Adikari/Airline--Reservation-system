var express = require('express');
var router = express.Router();

const {ResponseHandler} = require("../Controller/ResponseController");
const Method = require("../Controller/method");

const {login,register} = require("../Model/Authentication");
const { application } = require('express');



router.post('/login',async function(req, res){
    console.log("login");
    var method = new Method(req,res);
    
    var log_status = await login(method);
    // const viewUser = getCurrentUser();
    console.log(log_status.status, log_status.user);
    if(log_status.status){
        console.log("login1");
        res.render('user',{user:log_status.user});
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

// router.post('auth/logout',async function(req, res){
//     console.log("logout");
//     console.log(req.body.user);
//     var method = new Method(req,res);
//     const user = req.body.user;
//     await logout(user);
//     res.redirect('../login');
// });

// router.delete('/logout',async function(req, res){
    
//     //var method = new Method(req,res);
    
//     const status = await logout(req.user);

//     console.log(status);
    
//     res.status(ResponseHandler(status)).send(status);
    
// });

module.exports = router;