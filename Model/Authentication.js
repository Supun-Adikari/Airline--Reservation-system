const {hash,compare} = require("bcryptjs");
const {sign, verify} = require("jsonwebtoken");
const {executeSQL} = require("../Database/database");
const Method = require("../Controller/method");
const {RegUser} = require("./User");
const { parse } = require('querystring');
const ACCESS_TOKEN_SECRECT = "Group21Project"; //udj

var RegUsers = new Map();

async function register(method){

    const body = method.getBody();
    
    //registered_users table
    const UserName = body.username;
    const Password = body.password;
    const DoB = body.DoB;
    const Address = body.address;

    //users table
    const Title = body.title;
    const First_Name = body.fName;
    const Last_Name = body.lName;
    const Email = body.email;
    const Country = body.country;

    try{
        const [data] = await executeSQL('SELECT userName FROM registered_users WHERE userName = ?',[UserName]);
        
        if(data){

            return ("Error : Username already exists");
        
        }else{
            
            const hash_Password = await hash(Password,10);
            values = [Title,First_Name,Last_Name,DoB,Email,Country,UserName,hash_Password,Address];
            await executeSQL('CALL new_user_registered(?,?,?,?,?,?,?,?,?)',values)
            
            console.log(UserName + " successfuly added");
            return ("User added");
        }

    }catch(e){
        console.log(e);
        return ("Error");
        
        
    }      
}

async function login(method){

    const body = method.getBody();

    const username = body.username;
    const password = body.password;    
    try{
        const [validation] = await executeSQL('SELECT users.id, username , password_, f_Name, l_Name FROM users left join registered_users on users.id = registered_users.id WHERE registered_users.username =?',[username]);
        // console.log(validation.Password);
        console.log(validation);
        const status = await compare(password,validation.password_);
        const profile_ID = validation.id;
        const UserName = validation.username;
        const fname = validation.f_Name;
        const lname = validation.l_Name;
        
        if (status){

            var user =createUser(profile_ID,UserName,"Registered",fname,lname);
            console.log(user);

            if (RegUsers.has(profile_ID)){

                RegUsers.delete(username);

                await executeSQL('UPDATE sessions SET session_id = ?, end_time=? WHERE user_id= ?',[user.sessionID,Number(new Date().getTime()),user.profile_ID]);
                
                console.log("Logging out previous users");

            }else{

                try{

                    await executeSQL('INSERT INTO sessions VALUES (?,?,?)',[user.sessionID,user.profile_ID,Number(new Date().getTime())]);
                }
                catch(e){
                    console.log(e);
                    console.log("Error");
                }
            }
            
            RegUsers.set(profile_ID,user);

    
            const token = getAccessToken({sessionID:user.sessionID,profile_ID:user.profile_ID});
    
            //method.setToken(token,true,50000000);

            console.log(username + " Logged In Successfully !!!");

            return ({"token":token,"user":user,"status":true});

        }else{
            console.log(e)
            return("Error");
        }

    }catch(e){
        console.log(e);
        return("Error");
    }

    
    
}

async function logout(user){

    RegUsers.delete(user.profile_ID);

    try{
        await executeSQL('DELETE FROM sessions WHERE User_ID = ?',[user.profile_ID]);
    }
    catch(e){
        console.log("database error");
    }
    
    return(user.UserName + " Successfully Logged Out !!!")

}



const getAccessToken = (data)=>{
    token = sign(data, ACCESS_TOKEN_SECRECT,{algorithm: "HS256",expiresIn:"180m"});
    console.log(token);
    return token;
};


var ExtractRegUser =async function(req,res, next){

    var method = new Method(req,res);

    var token = method.getToken();
    console.log(token);
    try{
        const {sessionID,profile_ID} = verify(token,ACCESS_TOKEN_SECRECT);
        if(sessionID){
            
            var user = RegUsers.get(profile_ID);
            console.log(user);
            await user.setLastUsedTime();
            req.user = user;
        }

        next();
    }
    catch(err){
        console.log(err);
        console.log("Invaild token"); //when token expires
        res.sendStatus(203);
    }
}

var UpdateSession =async function(req,res, next){

    var method = new Method(req,res);

    var token = method.getToken();
    
    console.log(token);
    try{
        const {sessionID,profile_ID} = verify(token,ACCESS_TOKEN_SECRECT);
        if(sessionID){
            
            var user = RegUsers.get(profile_ID);
            console.log(user);
            await user.setLastUsedTime();
            req.user = user;
        }

        next();
    }
    catch(err){
        console.log("Invaild token or no token");
        next();
    }
}


var RestoreSession = async function(){

    console.log("Restoring Sessions");

    var data = null;

    try{
        [data] = await executeSQL('SELECT * FROM (sessions LEFT JOIN users on (sessions.User_Id = users.id)) LEFT JOIN registered_users on (sessions.User_Id = registered_users.id)');
    }catch(e){
        console.log(e);
        console.log("error");
    }
    //console.log(data);
   
    if (data == null){
        return;
    }
    for (const [key, value] of data.entries()){

        var user = createUser(value.profile_ID,value.UserName,"Registered",value.First_Name,value.Last_Name,value.Session_id,value.Last_used_time);
        RegUsers.set(value.profile_ID,user)
    
    }

    ShowCurrentUsers();
}


function createUser(profile_ID,username,type,fname,lname,sessionID,lastUsedTime){
    var user = new RegUser(profile_ID,username,type,fname,lname,sessionID,lastUsedTime);
    return(user)
}

function ShowCurrentUsers(){

    var CurrUsers = "Logged in: ";
    console.log(RegUsers.entries());
    for (const [key, value] of RegUsers.entries()){
        CurrUsers = CurrUsers + value.UserName + "  " ;
    }

    if (CurrUsers=="Logged in: "){
        console.log("Nobody Logged in");
    }else{
        console.log(CurrUsers);
    }
}

function getCurrentUser(user){
    return [user.UserName,user.fname,user.lname];
}

module.exports = {login,register,getAccessToken,ExtractRegUser,UpdateSession,RestoreSession,logout,ShowCurrentUsers};
