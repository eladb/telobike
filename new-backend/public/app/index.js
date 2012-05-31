$(document).bind('pageinit', function() {

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

  $.mobile.page.prototype.options.domCache = true; // http://jquerymobile.com/test/docs/pages/page-cache.html

  var current_location = null;
  var stations = null;

  function refresh() {
    if (!stations) return;

    $('#stations').empty();

    station_template = $('#tmpl-station').html();

    stations
      .map(function(s) {
        s.online = !!s.last_update;
        s.active = !s.online || s.available_bike > 0 || s.available_spaces > 0;
        s.status = determine_status(s);
        s.last_update_label = prettyDate(s.last_update);

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
  }

  function reload() {
    return $.get('/tlv/stations', function(result) {
      stations = result;
      refresh();
    });
  }

  var watch = navigator.geolocation.watchPosition(function(position) {
    current_location = [ position.coords.latitude, position.coords.longitude ];
    console.log('updated current location to:', current_location)
    refresh();
  });

  $('#refresh').click(function(e) {
    e.preventDefault();
    reload();
  });

  reload();

  function init_map() {
    var myLatlng = new google.maps.LatLng(-25.363882,131.044922);
    var myOptions = {
      zoom: 4,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    var marker = new google.maps.Marker({
        position: myLatlng,
        map: map,
        title:"Hello World!"
    });
  }

  init_map();

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

    var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
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

  //http://www.semicomplete.com/blog/geekery/jquery-mobile-full-height-content
  function fixgeometry() {
    /* Some orientation changes leave the scroll position at something
     * that isn't 0,0. This is annoying for user experience. */
    scroll(0, 0);

    /* Calculate the geometry that our content area should take */
    var header = $("[data-role='header']:visible");
    var footer = $("[data-role='footer']:visible");
    var content = $("[data-role='content']:visible");
    console.log(content);
    var viewport_height = $(window).height();
    
    var content_height = viewport_height - header.outerHeight() - footer.outerHeight();
    
    /* Trim margin/border/padding height */
    content_height -= (content.outerHeight() - content.height());
    console.log('content.height:', content_height);
    content.height(content_height);

    console.log('fixgeometry');
  };

  $(window).bind("orientationchange resize pageshow", fixgeometry);

});