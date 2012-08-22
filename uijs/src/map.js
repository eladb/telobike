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
    },
    invalidators: [ 'bounds' ],
  }));

  obj.bind('bounds', function() { 
    return this.x + ',' + this.y + '-' + this.width + 'x' + this.height; 
  });

  var native_map = nativeobj('UIJSMap', obj._id, {});

  // forward all events from `native_map` to `obj` (like!)
  native_map.forward(obj);

  // native_map.mock = true;

  var subscribed = false;

  obj.watch('bounds', function() {
    native_map.call('move', {
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height
    });

    // only subscribe *after* we did some positioning
    if (!subscribed) {
      
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

      subscribed = true;
    }
  });

  obj.ondraw = function(ctx) {
    if (!native_map.mock) {
      ctx.clearRect(0, 0, this.width, this.height);
    }
    else {
      ctx.fillStyle = 'white';
      ctx.fillRect(0, 0, this.width, this.height);
      ctx.strokeStyle = 'red';
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(this.width, this.height);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(this.width, 0);
      ctx.lineTo(0, this.height);
      ctx.stroke();
      ctx.strokeRect(0, 0, this.width, this.height);
    }
  };

  return obj;
}