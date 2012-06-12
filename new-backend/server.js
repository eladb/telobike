var express = require('express');
var path = require('path');

var server = express.createServer();
server.use(express.favicon(path.join(__dirname, 'public/img/favicon.png')));

var stations = require('./lib/tlv')();

var bridge = require('./lib/bridge');

function bridge_handler(req, res) {
  return bridge(function(err, stations) {
    if (err) {
      res.writeHead(500);
      return res.end(err.toString());
    }

    res.send(stations);
  });
}

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

console.log('telobike server started. listening on %s', process.env.port || 5000);
