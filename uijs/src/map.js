var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativebox = require('./nativebox');

module.exports = function(options) {
  var obj = nativebox(defaults(options, {
    type: 'UIJSMap',
    markers: [], // a marker contains at least { location: [ lat, long ] }
    region: {
      center: [ 0, 0 ],
      distance: [ 10, 10 ]
    },
    userLocation: {
      visible: false,
      track: true,
      heading: false
    },
  }));

  obj.on('init', function(native_map) {
    obj.watch('markers', function() {
      console.log('markers changed');
      native_map.call('set_markers', this.markers);
    });

    obj.watch('region', function() {
      console.log('region changed');
      native_map.call('set_region', this.region);
    });

    obj.watch('userLocation', function() {
      console.log('userLocation changed');
      native_map.call('set_user_location', this.userLocation);
    });      
  });

  return obj;
};