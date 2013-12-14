var express = require('express');
var path = require('path');
var logule = require('logule');
var cors = require('./lib/cors');
var server = express();
var csvdb = require('csvdb');
var telofun_api = require('./telofun-api');
var telofun_mapper = require('./telofun-mapper');

console.log('telobike server is running...');

var overrides_url = 'https://docs.google.com/spreadsheet/pub?key=0AuP9sJn-WbrXdFdOV1lPV09EZDBrQ2RlZzM5ZmhPb2c&output=csv';
var overrides_db = csvdb(overrides_url, { autofetch: 30 * 1000 }); // refresh overrides every 30s

setTimeout(function() {
  console.log(overrides_db.entries);
}, 5000);

server.use(express.logger({ format: 'dev' }));
server.use(express.methodOverride());
server.use(cors());
server.use(express.favicon(path.join(__dirname, 'public/img/favicon.png')));


var stations = {};

function read_stations(callback) {
  callback = callback || function() {};
  logule.trace('reading station information from tel-o-fun');

  return telofun_api(function(err, updated_stations) {
    if (err || !updated_stations) {
      console.error('error: unable to read telofun stations:', err);
      return callback(err);
    }

    console.log(updated_stations.length + ' stations retrieved');

    // map stations from tel-o-fun protocol to tel-o-bike protocol
    mapped_stations = updated_stations.map(telofun_mapper);

    // update cached stations
    stations = {};    
    mapped_stations.forEach(function(s) {
      if(s.IsActive !== '0'){
        stations[s.sid] = s;
      }
    });

    return callback(null, mapped_stations);
  });
}

setInterval(read_stations, 30*1000); // update station info every 30 seconds
read_stations();

setInterval(function() {
  var mb = Math.round(process.memoryUsage().heapTotal / 1024);
  logule.trace(mb + ' kb');
}, 2500);

function get_stations(req, res) {
  if (!stations) {
    res.writeHead(404);
    return res.end('no stations information from tel-o-fun');
  }

  var result = [];

  for (var sid in stations) {
    var s = stations[sid];

    var overrides = overrides_db.entries[sid];
    if (overrides) {
      console.log('found overrides for', sid);
      for (var k in overrides) {
        var val = overrides[k];
        if (val) {
          s[k] = val;
        }
      }
    }

    result.push(s);
  }

  return res.send(result);
}

server.get('/', function(req, res) {
  var host_parts = req.headers.host.split(':')[0].split('.');
  if (host_parts[0] === 'worldtour') {
    return res.redirect('http://www.tripcolor.com/user/53139/trip/C027FFEF-C4CF-4A4F-AA13-B8B11D1E4D75')
  }

  return res.redirect('http://itunes.apple.com/us/app/tel-o-bike-tel-aviv-bicycle/id436915919?mt=8');
});

server.get('/stations', get_stations);
server.get('/tlv/stations', get_stations);
server.get('/cities/tlv', function(req, res) {
  var city = {};
  city.city = "tlv";
  city.city_center = "32.0664,34.7779";
  city.city_name = "תל-אביב יפו";
  city['city_name.en'] = "Tel-Aviv";
  city.disclaimer = "Horray! The recent issues with the Tel-o-Fun database have been resolved. Enjoy cycling! Nir and Elad";
  city.info_url = "http://telobike.citylifeapps.com/static/en/tlv.html";
  city.info_url_he = "http://telobike.citylifeapps.com/static/he/tlv.html";
  city.last_update = "2011-06-15 18:47:50.982111";
  city.mail = "info@fsm-tlv.com";
  city.mail_tags = "This problem was reported via telobike";
  city.service_name= "תל-אופן";
  city['service_name.en'] = "Tel-o-Fun";
  return res.send(city);
});

server.post('/_deploy_dskfjh484jk09k', function(req, res) {
  var backoff_sec = Math.round(5 + Math.random() * 35); // between 5s and 30s
  console.log('deployment request. Exit in', backoff_sec + 's');
  setTimeout(function() {
    console.log('Bye');
    process.exit(0);
  }, backoff_sec * 1000);
  res.end('OK');
});

server.listen(process.env.port || 5000);

logule.trace('telobike server started. listening on %s', process.env.port || 5000);
