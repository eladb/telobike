var express = require('express');
var path = require('path');
var logule = require('logule');

var server = express.createServer();
server.use(express.favicon(path.join(__dirname, 'public/img/favicon.png')));

var stations = require('./lib/tlv')();

var bridge = require('./lib/bridge');

var stations = {};

function read_stations(callback) {
  callback = callback || function() {};
  logule.trace('Reading station information from tel-o-fun');
  return bridge('he', function(err, updated_stations) {
    if (err) {
      logule.error(err);
      return callback(err);
    }

    for (var sid in updated_stations) {
      var station = stations[sid];
      if (!station) stations[sid] = station = {};
      var updated_station = updated_stations[sid];
      for (var k in updated_station) {
        station[k] = updated_station[k];
      }
    }

    return callback(null, updated_stations);
  });
}

function read_en_stations(callback) {
  if (typeof callback !== 'function') callback = null;
  callback = callback || function() {};

  logule.trace('Merging en station names and addresses');
  
  return bridge('en', function(err, updated_en_stations) {
    if (err) { 
      logule.error(err);
      return callback(err);
    }

    for (var sid in updated_en_stations) {
      var en_station = updated_en_stations[sid];
      var station = stations[sid];
      if (!station) station = en_station;
      station.name_en = en_station.name;
      station.address_en = en_station.address;
    }

    return callback(null, updated_en_stations);
  });
}

setInterval(read_stations, 5000);
setInterval(read_en_stations, 30*60*1000); // update en names every 30 minutes

read_stations(function(err) {
  if (!err) read_en_stations();
});

function bridge_handler(req, res) {
  if (!stations) {
    res.writeHead(500);
    return res.end('No stations information from tel-o-fun');
  }

  var result = [];

  for (var sid in stations) {
    result.push(stations[sid]);
  }

  return res.send(result);
}

server.get('/', function(req, res) {
  return res.redirect('http://itunes.apple.com/us/app/tel-o-bike-tel-aviv-bicycle/id436915919?mt=8');
});
server.get('/stations', bridge_handler);
server.get('/tlv/stations', bridge_handler);
server.get('/cities/tlv', function(req, res) {
  var city = {};

  city.city = "tlv";
  city.city_center = "32.0664,34.7779";
  city.city_name = "תל-אביב יפו";
  city['city_name.en'] = "Tel-Aviv";
  city.disclaimer = "Yo, the real-time station status is taken directly from the official\nTel-o-Fun website. In cases where the data is not accurate, we recommend sending \"feedback about the bike service\".\n\nEnjoy and thanks for all your great inputs about the app!\nNir and Elad";
  city.info_url = "http://telobike.citylifeapps.com/static/en/tlv.html";
  city.info_url_he = "http://telobike.citylifeapps.com/static/he/tlv.html";
  city.last_update = "2011-06-15 18:47:50.982111";
  city.mail = "info@fsm-tlv.com";
  city.mail_tags = "This problem was reported via telobike";
  city.service_name= "תל-אופן";
  city['service_name.en'] = "Tel-o-Fun";

  return res.send(city);
})

// server.get('/tlv/stations', function(req, res) {
//   return stations.all(function(err, stations) {
//     if (err) return res.send(err);

//     var arr = [];
//     for (var id in stations) {
//       var s = stations[id];
//       s.url = '/tlv/stations/' + id;
//       arr.push(s);
//     }

//     return res.send(arr);
//   });
// });

// server.get('/tlv/stations/:id', function(req, res) {
//   stations.one(req.params.id, function(err, station) {
//     if (err) return res.send(err);
//     return res.send(station);
//   });
// });

// server.use(express.static(path.join(__dirname, 'public')));

server.listen(process.env.port || 5000);

// var REFRESH_INTERVAL = 5 * 60 * 1000; // every 5 minutes
// setInterval(function() {
//   console.log('Refresh stations');
//   stations.refresh();
// }, REFRESH_INTERVAL);

// stations.refresh(); // refresh upon start

logule.trace('telobike server started. listening on %s', process.env.port || 5000);
