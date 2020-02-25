var http = require('http');
var os = require("os");
var hostname = os.hostname();

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(`fuck all! ${hostname}`);
}).listen(3317);
