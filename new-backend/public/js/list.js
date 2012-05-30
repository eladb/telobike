var MARGINAL = 3;

$(function() {
  var current_location = null;

  function reload() {
    station_template = $('#tmpl-station').html();

    $.get('/tlv/stations', function(stations) {

      $('#stations').empty();

      stations.forEach(function(station) {

        station.online = !!station.last_update;
        station.active = !station.online || station.available_bike > 0 || station.available_spaces > 0;
        station.status = determine_status(station);

        if (current_location) {
          station.distance = calculate_distance([ station.latitude, station.longitude ], current_location);
        }

        $('#stations').append($(Mustache.to_html(station_template, station)));
      });

      $('#stations').listview('refresh');
    });
  }

  function calculate_distance(l1, l2) {
    return '12m';
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