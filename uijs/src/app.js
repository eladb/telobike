var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');
var animate = uijs.animation;
var positioning = uijs.positioning;
var image = require('uijs-controls').image;
var loadimage = uijs.util.loadimage;
var panel = require('./station-panel');

function map(options) {
  var obj = box(defaults(options, {
    markers: [], // a marker contains at least { location: [ lat, long ] }
    region: {
      center: [ 0, 0 ],
      distance: [ 10, 10 ],
    },
    userLocation: {
      visible: false,
      track: true,
      heading: false,
    },
  }));

  var native_map = nativeobj('UIJSMap', obj._id, {});

  // forward all events from `native_map` to `obj` (like!)
  native_map.forward(obj);

  var last_bounds;

  obj.watch = function(attr_or_fn, callback) {
    var self = this;

    if (typeof attr_or_fn !== 'function') {
      var attr = attr_or_fn;
      attr_or_fn = function() {
        return self[attr];
      }
    }

    var last_value = null;
    obj.on('frame', function() {
      var curr_value = JSON.stringify(attr_or_fn()); // serialize
      if (last_value !== curr_value) {
        callback.call(self, curr_value, last_value);
        last_value = curr_value;
      }
    });
  };

  obj.watch(
    function() { return obj.x + ',' + obj.y + '-' + obj.width + 'x' + obj.height; }, 
    function() {
      native_map.call('move', {
        x: obj.x,
        y: obj.y,
        width: obj.width,
        height: obj.height
      });
    });

  obj.watch('markers', function() {
    native_map.call('set_markers', obj.markers);
  });

  obj.watch('region', function() {
    native_map.call('set_region', obj.region);
  });

  obj.watch('userLocation', function() {
    native_map.call('set_user_location', obj.userLocation);
  });

  obj.ondraw = function(ctx) {
    ctx.clearRect(0, 0, this.width, this.height);
  };

  var last_bounds;

  return obj;
}

var app = box();

var TLV = {
  center: [32.0696, 34.7781],
  distance: [1000,1000],
};

var map1 = app.add(map({
  height: positioning.parent.height(),
  width: positioning.parent.width(),
  title: 'Map1',
  region: TLV,
}))


var model = require('./model').createModel();

model.on('update', function() {
  console.log('new markers:', model.stations);
  map1.markers = model.stations;
});

var p = app.add(panel({
  id: '#panel',
  x: positioning.parent.centerx(), 
  y: -167,
  station: function() { return map1.current_marker; },
}));

map1.on('marker-selected', function(m) {
  map1.region = {
    center: m.location,
    distance: [1000, 1000], // 1km
  };

  map1.current_marker = m;
  p.animate({ y: 0 });
});

map1.on('marker-deselected', function() {
  p.animate({ y: -167 }, { ondone: function() {
    map1.current_marker = null;
  }});
});

map1.on('move', function() {
  p.animate({ y: -167 });
});

module.exports = app;