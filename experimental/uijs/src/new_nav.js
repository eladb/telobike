var uijs = require('uijs');
var controls = require('uijs-controls');
var button = controls.button;
var label = controls.label;
var EventEmitter = uijs.events.EventEmitter;
var box = uijs.box;
var positioning = uijs.positioning;
var defaults = uijs.util.defaults;

function boxy(options) {
  var obj = label(defaults(options, {
    color: 'red'
  }));

  obj.ondraw = function(ctx) {
    ctx.fillStyle = this.color;
    ctx.fillRect(0, 0, this.width, this.height);
  };

  return obj;
}

var map = boxy({ id: 'map', text: 'map!' });

function fade(prev, curr) {
  prev && prev.animate({ alpha: 0.0 }, options);
  curr.animate({ alpha: 1.0 }, options);
}

var list = boxy({ 
  id: 'list', 
  text: 'list!',
  onshow: fade,
  onhide: fade,
});


var router = createRouter();
router.x = 0;
router.y = 0;
router.width = positioning.parent.width();
router.height = positioning.parent.height();
router.page('/map', map);
router.page('/list', list);
router.navigate('/map');
router.on('click', function() {
  router.navigate('/list');
});

var app = boxy();
app.add(router);
module.exports = app;

