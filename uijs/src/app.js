var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');
var animate = uijs.animation;
var positioning = uijs.positioning;
var image = require('uijs-controls').image;
var loadimage = uijs.util.loadimage;
var bind = uijs.bind;
var telobike_map = require('./telobike-map');
var telobike_lv = require('./telobikeListView');

var app = box({
  id: 'app',
});

var model = require('./model').createModel();

var map = app.add(telobike_map({
  id: 'telobike_map',
  x: bind(positioning.parent.width()),
  width: bind(positioning.parent.width()),
  height: bind(positioning.parent.height()),
  model: model,
}));

var lv = app.add(telobike_lv({
  id: 'telobike_listview',
  x: 0, y: 0,
  width: bind(positioning.parent.width()),
  height: bind(positioning.parent.height()),
  model: model,
}));

lv.on('click', function(item) {
  lv.animate({ x: function() { return -this.parent.width; } });
  map.animate({ x: 0 }, { ondone: function() {
    map.select(item);
  }});
});

map.on('back', function() {
  lv.animate({ x: 0 });
  map.animate({ x: function() { 
    return this.parent.width; 
  }});
});

module.exports = app;