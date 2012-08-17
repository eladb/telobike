var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');

module.exports = function(options) {
  var obj = box(defaults(options, {
    markers: [], // a marker contains at least { location: [ lat, long ] }
    region: {
      center: [ 0, 0 ],
      distance: [ 10, 10 ]
    },
    userLocation: {
      visible: false,
      track: true,
      heading: false
    }
  }));

  var native_map = nativeobj('UIJSMap', obj._id, {});

  // forward all events from `native_map` to `obj` (like!)
  native_map.forward(obj);

  var last_bounds;

  obj.monitor = function(attr_or_fn, callback) {
    var self = this;

    if (typeof attr_or_fn !== 'function') {
      var attr = attr_or_fn;
      attr_or_fn = function() {
        return self[attr];
      }
    }

    var last_value = null;
    self.on('frame', function() {
      var curr_value = JSON.stringify(attr_or_fn.call(self)); // serialize
      if (last_value !== curr_value) {
        callback.call(self, curr_value, last_value);
        last_value = curr_value;
      }
    });
  };

  obj.monitor(
    function() { return this.x + ',' + this.y + '-' + this.width + 'x' + this.height; }, 
    function() {
      native_map.call('move', {
        x: this.x,
        y: this.y,
        width: this.width,
        height: this.height
      });

      obj.watch('markers', function() {
        native_map.call('set_markers', this.markers);
      });

      obj.watch('region', function() {
        native_map.call('set_region', this.region);
      });

      obj.watch('userLocation', function() {
        native_map.call('set_user_location', this.userLocation);
      });

    });

  obj.ondraw = function(ctx) {
    ctx.clearRect(0, 0, this.width, this.height);
  };

  var last_bounds;

  return obj;
}