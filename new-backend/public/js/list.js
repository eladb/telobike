var MARGINAL = 3;

/** Converts numeric degrees to radians */
if (typeof(Number.prototype.toRad) === "undefined") {
  Number.prototype.toRad = function() {
    return this * Math.PI / 180;
  }
}

/** Converts radians to numeric (signed) degrees */
if (typeof(Number.prototype.toDeg) === "undefined") {
  Number.prototype.toDeg = function() {
    return this * 180 / Math.PI;
  }
}

$(function() {
  var current_location = null;

  function reload() {
    station_template = $('#tmpl-station').html();

    $.get('/tlv/stations', function(stations) {

      $('#stations').empty();

      stations
        .map(function(s) {
          s.online = !!s.last_update;
          s.active = !s.online || s.available_bike > 0 || s.available_spaces > 0;
          s.status = determine_status(s);
  
          if (current_location) {
            var d = calculate_distance([ s.latitude, s.longitude ], current_location);
            var dl = d < 1.0 ? (d * 1000).toFixed(1) + 'm' : d.toFixed(1) + 'km';
            s.distance = d;
            s.distance_label = dl;
          }

          return s;
        })
        .sort(function(s1, s2) { 
          return s1.distance - s2.distance; 
        })
        .forEach(function(s) {
          $('#stations').append($(Mustache.to_html(station_template, s)));
        });

      $('#stations').listview('refresh');
    });
  }

  // http://www.movable-type.co.uk/scripts/latlong.html
  function calculate_distance(l1, l2) {
    var lat1 = parseFloat(l1[0]);
    var lon1 = parseFloat(l1[1]);
    var lat2 = parseFloat(l2[0]);
    var lon2 = parseFloat(l2[1]);

    var R = 6371; // km
    var dLat = (lat2-lat1).toRad();
    var dLon = (lon2-lon1).toRad();
    var lat1 = lat1.toRad();
    var lat2 = lat2.toRad();

    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    var d = R * c;

    return d;
  }

  function determine_status(station) {
    if (!station.online) return 'unknown';
    if (!station.active) return 'inactive';
    if (station.available_bike === 0) return 'empty';
    if (station.available_spaces === 0) return 'full';
    if (station.available_bike <= MARGINAL) return 'hempty';
    if (station.available_spaces <= MARGINAL) return 'hfull';
    return 'okay';
  }

  navigator.geolocation.watchPosition(function(position) {
    current_location = [ position.coords.latitude, position.coords.longitude ];
    console.log('updated current location to:', current_location)
    reload();
  });

  reload();
});