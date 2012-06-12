var request = require('request');
var jsdom = require('jsdom');
var MemoryStream = require('memstream').MemoryStream;
var zlib = require('zlib');
var urlparse = require('url').parse;
var fs = require('fs');

module.exports = function(url, callback) {
  var purl = urlparse(url);
  
  if (purl.protocol === 'file:') {
    return fs.readFile(purl.path, function(err, body) {
      if (err) return callback(err);
      return jsdomize(body, callback);
    });
  }

  var req = request(url);

  req.on('error', function(err) {
    return callback(err);
  });

  req.on('response', function(res) {
    var output = new MemoryStream();
    var body = '';

    output.on('data', function(data) {
      body += data.toString();
    });

    switch (res.headers['content-encoding']) {
      case 'gzip':
        res.pipe(zlib.createGunzip()).pipe(output);
        break;
      
      case 'deflate':
        res.pipe(zlib.createInflate()).pipe(output);
        break;
      
      default:
        res.pipe(output);
        break;
    }

    output.on('end', function() {
      return jsdomize(body, callback);
    });
  });

  function jsdomize(body, callback) {
    return jsdom.env({
      html: body,
      scripts: [ 'http://code.jquery.com/jquery-1.5.min.js' ], 
      done: function(err, window) {
        if (err) return callback(err);
        else return callback(null, window.$);
      }
    });
  }
}