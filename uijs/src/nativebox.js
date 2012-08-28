var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');

module.exports = function(options) {
  var obj = box(defaults(options, {
  }));

  if (!obj.type) throw new Error('options.type is required');

  obj.invalidators = obj.invalidators || [];
  obj.invalidators.push('bounds');

  obj.bind('bounds', function() { 
    return this.x + ',' + this.y + '-' + this.width + 'x' + this.height; 
  });

  var native_view = nativeobj(obj.type, obj._id, {});

  // forward all events from `native_view` to `obj` (like!)
  native_view.forward(obj);

  var subscribed = false;

  obj.watch('bounds', function() {
    native_view.call('move', {
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height
    });

    // only subscribe *after* we did some positioning
    if (!subscribed) {
      obj.emit('init', native_view);
      subscribed = true;
    }
  });

  obj.ondraw = function(ctx) {
    if (!native_view.mock) {
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