var express = require('express');
var path = require('path');
var logule = require('logule');
var cors = require('./lib/cors');
var server = express();
var csvdb = require('csvdb');
var telofun_api = require('./lib/telofun-api');
var telofun_mapper = require('./lib/telofun-mapper');
var AWS = require('aws-sdk');
var async = require('async');

AWS.config.region = 'eu-west-1';

var s3bucket = new AWS.S3({ params: { Bucket: 'telobike' } });

console.log('telobike server is running...');

var overrides_url = 'https://docs.google.com/spreadsheets/d/1qjbQfj2vDWc569PIXJ-i8-2uLQk3KC1P4mz3bpGUJxI/pub?output=csv';
var s3_url_prefix = 'https://s3-eu-west-1.amazonaws.com/telobike';

server.use(express.logger());
server.use(express.methodOverride());
server.use(cors());
server.use(express.favicon(path.join(__dirname, 'public/img/favicon.png')));

var last_read_status = {
  time: 'never',
  api: 'unknown',
  overrides: 'unknown',
  s3: 'unknown',
};

var stations = {};

function render_stations(callback) {
  callback = callback || function() {};
  logule.trace('reading station information from tel-o-fun');

  last_read_status = {
    time: new Date(),
    api: 'pending',
    overrides: 'pending',
    s3: 'pending',
  };

  return telofun_api(function(err, updated_stations) {
    if (err || !updated_stations) {
      if (!err) err = new Error('stations array is empty');
      last_read_status.api = 'Error: ' + err.message;
      console.error('error: unable to read telofun stations:', err);
      return callback(err);
    }

    console.log(updated_stations.length + ' stations retrieved');
    last_read_status.api = 'Loaded ' + updated_stations.length.toString() + ' stations';

    // map stations from tel-o-fun protocol to tel-o-bike protocol
    var mapped_stations = updated_stations.map(telofun_mapper);

    // update cached stations
    stations = { };    
    mapped_stations.forEach(function(s) {
      if(s.IsActive !== '0'){
        stations[s.sid] = s;
      }
    });

    return csvdb(overrides_url, function(err, all_overrides) {
      if (err) {
        last_read_status.overrides = 'Error: ' + err.message;
      }
      else {
        last_read_status.overrides = 'Success. Loaded ' + Object.keys(all_overrides).length.toString() + ' overrides';

        // merge overrides
        merge_overrides(stations, all_overrides);
      }

      // write stations to S3
      upload_to_s3(stations, function(err) {
        if (err) {
          console.error('ERROR: upload to s3 failed:', err);
          last_read_status.s3 = 'Error: ' + err.message;
        }
        console.log('Uploaded to S3');
        last_read_status.s3 = 'Uploaded';
      });

      return callback(null, stations);
    });
  });
}

function upload_to_s3(stations, callback) {
  var array = Object.keys(stations).map(function(key) { return stations[key] });
  var params = { Key: 'tlv/stations.json', Body: JSON.stringify(array, true, 2), ACL: 'public-read' };
  return s3bucket.upload(params, callback);
}

function merge_overrides(stations, all_overrides) {
  for (var sid in stations) {
    var s = stations[sid];

    var overrides = all_overrides[sid];
    if (overrides) {
      console.log('found overrides for', sid);
      for (var k in overrides) {
        var val = overrides[k];
        if (val) {
          s[k] = val;
        }
      }
    }  
  }
}

setInterval(render_stations, 30*1000); // update station info every 30 seconds
render_stations();

function get_tlv_stations(req, res) {
  return res.redirect(s3_url_prefix + '/tlv/stations.json');
}

function get_tlv_city(req, res) {
  return res.redirect(s3_url_prefix + '/tlv/city.json');
}

server.get('/', function(req, res) {
  return res.redirect('http://itunes.apple.com/us/app/tel-o-bike-tel-aviv-bicycle/id436915919?mt=8');
});

server.get('/stations', get_tlv_stations);
server.get('/tlv/stations', get_tlv_stations);
server.get('/cities/tlv', get_tlv_city);

server.get('/status', function(req, res) {
  res.send(last_read_status);
});

server.get('/ping', function(req, res) {
  return telofun_api(function(err, stations) {
    if (err) {
      res.status(500);
      return res.send({ error: err });
    }

    return res.send('OK');
  });
});

server.post('/push', function(req, res, next) {
  console.log('received push token:', req.url);
  return res.send('OK');
});

setInterval(function() {
  var mb = Math.round(process.memoryUsage().heapTotal / 1024);
  logule.trace(mb + ' kb');
}, 2500);

server.listen(process.env.port || 5000);

logule.trace('telobike server started. listening on %s', process.env.port || 5000);