function ResponseHandler(status){
    if (status=="Error"){
        return(400);
    }else if(status == "AccessDenied"){
        return(203);
    }else{
        return(200);
    }
}

module.exports =  {ResponseHandler};




// async function customHeaders(token) {
//     const config = {
//       headers: {
//         'Content-Type': 'application/json',
//         Authorization: token
//       }
//     };
  
//     await axios
//       .get(
//         "/registered",
//         config
//       )
//       .then(res => showOutput(res))
//       .catch(err => console.error(err));
//   }