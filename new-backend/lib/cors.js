// see: http://stackoverflow.com/questions/7067966/how-to-allow-cors-in-express-nodejs
module.exports = function() {
  return function(req, res, next) {

    var requestHeaders = req.headers && req.headers['Access-Control-Request-Headers'];
    var allowHeaders = requestHeaders ? requestHeaders : 'Content-Type, Authorization';

    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
    res.header('Access-Control-Allow-Headers', allowHeaders);

    if (req.method === 'OPTIONS') {
      res.send(200);
    }
    else {
      next();
    }
  }
};