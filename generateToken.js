
const mysql = require('mysql2');
const{RtcTokenBuilder, RtcRole} = require('agora-access-token');
const connection = mysql.createConnection({
    host: '10.0.2.2',
    port: 3306,
    user: 'root',
    password: 'password',
    database: 'tfg_database',
});
async function getUserIdAndGenerateToken(email, isTeacher, expirationInSeconds){
    connection.query(
        'SELECT id FROM users WHERE email = ?',
        [
            email,
        ],
        (err,result)=>{
            if(err){
                console.error('Error al obtener el Id del usuario', err);
               return;
            }

            if(result.length === 0){
              console.error('Usuario no encontrado');
              return;
            }

            const userID = result[0].id;
            const appID = 'c42393923a754eba9a20b5c4ed70e0ce';
            const appCertificate = 'f346e24378b94abdb4d7e626685315d7';
            const channelName = 'tfg';
            const role = isTeacher? RtcRole.teacher : RtcRole.student;
            const token = generateAgoraToken({appID, appCertificate,channelName,uid:userID,role,expirationInSeconds});
            console.log('generateToken', token);

        }
    )
}
function generateAgoraToken({appID, appCertificate,channelName,uid,role,expirationInSeconds}){
    const currentTimestamp = Math.floor(Date.now()/1000);
    const privilegedExpiredTs = currentTimestamp + expirationInSeconds;
    const token = RtcTokenBuilder.buildTokenWithUid(
        appID,appCertificate,channelName,uid,role,privilegedExpiredTs
    );
    return token;
}


const email = 'rodrigo123@gmail.com';
const isTeacher = true;
const expirationInSeconds = 3600;
getUserIdAndGenerateToken(email,isTeacher,expirationInSeconds);


