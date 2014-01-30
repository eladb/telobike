var x$ = require('xui');
var uijs = require('uijs');
var EventEmitter = uijs.events.EventEmitter;
var util = uijs.util;
var preloaded = require('./preloaded-stations');

exports.createModel = function() {

  var obj = new EventEmitter();

  obj.stations = preloaded;

  if (typeof Number.prototype.toRad == 'undefined') {
    Number.prototype.toRad = function() {
      return this * Math.PI / 180;
    }
  }

  var current_position = null;

  function notify_update() {
    var stations = obj.stations;

    stations.forEach(function(s) {
      s.location = [ s.latitude, s.longitude ];
      s.status = determine_status(s);
      s.image = 'assets/img/map_' + s.status + '.png';
      s.list_image = 'assets/img/list_' + s.status + '.png';
      s.center = [ 6.0, -18.0 ];

      if (current_position) {
        s.distance = getDistance(s.latitude, s.longitude, current_position.coords.latitude, current_position.coords.longitude);
      }

      // These will create a callout:
      // s.title = s.name;
      // s.subtitle = s.available_bike + ' bicycles ' + s.available_spaces + ' slots';
      // s.icon = 'assets/img/list_' + s.status + '.png';
    });

    obj.emit('update', stations);
  }

  function reload() {
    x$().xhr('http://telobike.citylifeapps.com/stations', {
      async: true,
      callback: function(items) {
        try {
          var stations = JSON.parse(this.responseText);
          console.log('Response with ' + stations.length + ' stations');
          obj.stations = stations;
          notify_update();
        }
        catch (e) {
          console.error('parse error:', e);
        }
      },
    });
  }

  navigator.geolocation.getCurrentPosition(function(position) {
    current_position = position;
  });

  function determine_status(station) {
    if (station.available_bike === 0 || station.available_bike === '0') return 'empty';
    if (station.available_spaces === 0 || station.available_spaces === '0') return 'full';
    if (station.available_bike <= 3) return 'hempty';
    if (station.available_spaces <= 3) return 'hfull';
    return 'okay';
  }

  function getDistance(lat1,lon1,lat2,lon2) {
    var R = 6371; // km
    var dLat = (lat2-lat1).toRad();
    var dLon = (lon2-lon1).toRad(); 
    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1.toRad()) * Math.cos(lat2.toRad()) * 
            Math.sin(dLon/2) * Math.sin(dLon/2); 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    //return distance in meters
    return Math.round(R * c * 1000);
  }

  reload();
  setInterval(reload, 30000); // refresh every 30sec

  setTimeout(function() {
    console.log('updating stations...');
    notify_update();
  }, 100);

  return obj;
}

