var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');
var animate = uijs.animation;
var positioning = uijs.positioning;
var image = require('uijs-controls').image;
var loadimage = uijs.util.loadimage;
var panel = require('./station-panel');
var bind = uijs.bind;
var map = require('./map');

var app = box();

var TLV = {
  center: [32.0696, 34.7781],
  distance: [1000,1000],
};

var map1 = app.add(map({
  height: bind(map1, 'height', positioning.parent.height()),
  width: bind(map1, 'width', positioning.parent.width()),
  title: 'Map',
  region: TLV,
}));

var model = require('./model').createModel();

model.on('update', function() {
  map1.markers = model.stations;
});

var p = app.add(panel({
  id: '#panel',
  x: 320/2-276/2,//bind(p, 'x', positioning.parent.centerx()), 
  y: -167,
  station: bind(p, 'station', function() { return map1.current_marker; }),
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

// app.ondraw = function(ctx) {
//   ctx.fillStyle = 'blue';
//   ctx.fillRect(5, 5, 320-10, 460-10);
// };

module.exports = app;