var x$ = require('xui');
var uijs = require('uijs');
var EventEmitter = uijs.events.EventEmitter;
var util = uijs.util;

exports.createModel = function() {

  var obj = new EventEmitter();

  obj.stations = [];

  function reload() {

    x$().xhr('http://telobike.citylifeapps.com/stations', {
      async: true,
      callback: function(items) {
        var stations = JSON.parse(this.responseText);

        console.log('Response with ' + stations.length + ' stations');

        stations.forEach(function(s) {
          s.location = [ s.latitude, s.longitude ];
          s.status = determine_status(s);
          s.image = 'assets/img/map_' + s.status + '.png';
          s.list_image = util.loadimage('assets/img/list_' + s.status + '.png');
          s.center = [ 6.0, -18.0 ];

          // These will create a callout:
          // s.title = s.name;
          // s.subtitle = s.available_bike + ' bicycles ' + s.available_spaces + ' slots';
          // s.icon = 'assets/img/list_' + s.status + '.png';
        });

        var prev = obj.stations;
        obj.stations = stations;
        obj.emit('update', stations, prev);
      },
    });

  }

  function determine_status(station) {
    if (station.available_bike === 0) return 'empty';
    if (station.available_spaces === 0) return 'full';
    if (station.available_bike <= 3) return 'hempty';
    if (station.available_spaces <= 3) return 'hfull';
    return 'okay';
  }

  reload();
  setInterval(reload, 30000); // refresh every 30sec

  return obj;
}

