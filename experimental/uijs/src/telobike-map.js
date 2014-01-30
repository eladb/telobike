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
var button = require('./uijs-controls').button;
var map = require('./map');

var TLV = {
  center: [32.0696, 34.7781],
  distance: [1000,1000],
};

module.exports = function (options) {
  var obj = map(defaults(options, {
    model: null,
    region: TLV,
  }));

  obj.watch('model', function() {
    if (!obj.model) return;
    
    obj.model.on('update', function() {
      obj.markers = obj.model.stations;
    });
  });

  var p = obj.add(panel({
    id: '#panel',
    x: bind(positioning.parent.centerx()),
    y: -167,
    station: bind(function() { return obj.current_marker; }),
  }));

  obj.select = function(m) {
    obj.region = {
      center: m.location,
      distance: [1000, 1000], // 1km
    };

    obj.current_marker = m;
    p.animate({ y: 0 });
  };

  obj.on('marker-selected', function(m) {
    obj.select(m);
  });

  function collapse_panel() {
    p.animate({ y: -167 }, { 
      ondone: function() {
        obj.current_marker = null;
      }
    });
  }

  obj.on('marker-deselected', collapse_panel);
  obj.on('move', collapse_panel);

  var back = obj.add(button({
    x: 10,
    y: 10,
    size: 12,
    width: 80,
    height: 20,
    text: 'back',
    color: 'white',
    background: 'black',
  }));

  back.on('click', function() {
    obj.emit('back');
  });

  return obj;
};