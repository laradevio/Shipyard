console.log(`
  Initializing Example index.js. \n
    ~~~
  You are free to copy this file to your Application Directory
  and tinker with it to make your next project awesome. ;)
`)

/**
 * Ensure we are using our Application path as working directory
 */
try {
	process.chdir('/var/www');
	console.log('Speaker - Working in: ' + process.cwd());
}
catch (err) {
	console.log('Speaker - Error changing directory: ' + err);
}

/**
 * Initialize our modules
 */ 
var fs = require('fs');
var privateKey = fs.readFileSync('/secrets/ssl/certs/shipyard-server-key.pem');
var certificate = fs.readFileSync('/secrets/ssl/certs/shipyard-server-cert.pem');
var credentials = {key: privateKey, cert: certificate};

/**
 * Options for the server
 */
var httpsPort = 6001;
var redisHost = 'shipyard_speaker-redis';
var redisPort = 6379;

/**
 * Initialize Express, the HTTPS Server and Socket.io
 */
var app = require('express')();
var https = require('https').Server(credentials, app);
var io = require('socket.io')(https);


/**
 * Sample Code to run the Aplication.
 */
app.get('/', function(req, res){
  res.send('<h1>Shipyard Speaker is running</h1>');
});


/**
 * Listen for private events
 */
https.listen(httpsPort, function(){
  console.log('Speaker - Listening events on port :' + httpsPort);
});


/**
 * Socket.io functions
 */
io.on('connection', function(socket){
  console.log('A user has connected.');
  socket.on('disconnect', function(){
    console.log('A user has disconnected.');
  });
});
