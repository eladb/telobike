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
var telobike_tabbar = require('./telobike-tabbar');
var navbar = require('./navbar');
// var telobike_navbar = require('./telobike-navbar');

var app = box({ id: 'app' });

var model = require('./model').createModel();

var nav = app.add(navbar());

nav.push_item({ title: 'List' });

var tabbar = app.add(telobike_tabbar());



var content = app.add(box({
  x: 0,
  y: 44,
  width: bind(positioning.parent.width()),
  height: bind(positioning.parent.height(-50-44)),
  clip: true,
}));

var map = telobike_map({
  id: 'telobike_map',
  y: 0,
  x: bind(positioning.parent.width()),
  width: bind(positioning.parent.width()),
  height: bind(positioning.parent.height()),
  model: model,
  title: 'Map',
});

var lv = telobike_lv({
  id: 'telobike_listview',
  x: 0, y: 0,
  width: bind(positioning.parent.width()),
  height: bind(positioning.parent.height()),
  model: model,
  title: 'List',
});

// navbar.on('init', function() {
//   this.push_box(lv);
// });

// lv.on('click', function() {
//   navbar.push_box(map);
// });

content.add(lv);
content.add(map);

tabbar.watch('selected', function(tabid) {
  switch (tabid) {
    case 'list': 
      lv.x = 0;
      map.bind('x', positioning.parent.width());
      // navbar.clear_items();
      // navbar.push_item({ title: 'List' });
      // navbar.push_item({ title: 'Map' });
      // navbar.pop_item({ title: 'Map' });
      break;

    case 'map':
      map.x = 0;
      lv.bind('x', function() { return -this.parent.width; });
      // navbar.push_item({ title: 'Map' });
      break;
  }
});

// navbar.on('pop', function() {
//   tabbar.selected = 'list';
// });

lv.on('click', function(item) {
  // navbar.selected = 'map';
  // navbar.push_item({ title: 'Map' });
  // navbar.on('pop', function() {
  //   map.emit('back');
  // });
  lv.animate({ x: function() { return -this.parent.width; } });
  map.animate({ x: 0 }, { ondone: function() {
    tabbar.selected = 'map';
    map.select(item);
  }});
});

map.on('back', function() {
  // navbar.selected = 'list';
  lv.animate({ x: 0 });
  map.animate({ x: positioning.parent.width() }, { ondone: function() {
    tabbar.selected = 'list';
  }});
});

module.exports = app;