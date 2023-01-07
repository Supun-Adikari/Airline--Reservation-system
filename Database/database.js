
var mysql = require('mysql2');
const dotenv = require('dotenv');
dotenv.config();


const dbSettings = {
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE,
}

var pool = mysql.createPool(dbSettings);

function executeSQL(sql,placeholder){
    return new Promise((res,rej)=>{
        pool.getConnection((err, connection) => {
            if (err) throw err; // not connected!
           
            // Use the connection
            connection.query(sql,placeholder, async (error, results, fields)=> {

                // When done with the connection, release it.
                connection.release();
            
                // Handle error after the release.
                if (error){
                    rej({error});
                }
                res(results);
            
                // Don't use the connection here, it has been returned to the pool.
            });
          });
    });
}

// exports.executeSQL = executeSQL;
module.exports = {executeSQL};
