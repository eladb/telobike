var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');
var animate = uijs.animation;
var positioning = uijs.positioning;
var controls = require('uijs-controls');
var image = controls.image;
var loadimage = uijs.util.loadimage;
var label = controls.label;
var button = controls.button;
var rect = controls.rect;
var bind = uijs.bind;

module.exports = function(options) {

  //TODO: we can probably save quite a few binds if we use positioning more stinchly. 
  //      If we have perf issues, we should try it.

  function statusbox(options) {
    var obj = box(defaults(options, {
      width: 121, height: 58,
      count: 4,
      icon: loadimage('assets/img/icon_parking.png'),
      status: bind(function() {
        if (this.count === 0) return 'red';
        if (this.count <= 3) return 'yellow';
        else return 'green';
      }),
    }));

    var backgrounds = {
      green: loadimage('assets/img/greenbox.png'),
      red: loadimage('assets/img/redbox.png'),
      yellow: loadimage('assets/img/yellowbox.png'),
    };

    var background_image = obj.add(image({
      image: bind(function() { return backgrounds[obj.status]; }),
      width: 121, height: 58,
    }));

    var icon_image = obj.add(image({
      image: bind(function() { return obj.icon; }),
      width: 121/2, height: 58,
      x: 1, y: 1,
    }));

    var count_label = obj.add(label({
      text: bind(function() { return obj.count; }),
      color: 'white',
      size: 40,
      font: 'Helvetica',
      x: bind(positioning.prev.right()), 
      y: bind(positioning.prev.top(5)),
      width: 121/2-5,
      height: 48,
    }));

    return obj;
  }

  var obj = box(defaults(options, {
    width: 276, 
    height: 167,
    station: {
      name: '108 Rotchild Ave.',
      available_bike: 4,
      available_spaces: 2,
    },
  }));

  console.log(obj.interaction);

  var bg = obj.add(image({
    x: 0, y: -6, width: 276, height: 167,
    image: loadimage('assets/img/panel.png'),
  }));

  var name_label = bg.add(label({
    id: '#name',
    x: 10, 
    y: 10,
    width: bind(positioning.parent.width(-20)),
    height: 35,
    // adjustsFontSizeToFitWidth: 20,
    size: 20,
    color: 'white',
    shadowColor: 'white',
    shadowBlur: 10,
    text: bind(function() {
      return obj.station && obj.station.name;
    }),
  }));

  var bike_status = bg.add(statusbox({ 
    id: '#bicycle',
    icon: loadimage('assets/img/icon_bike.png'),
    x: 15, 
    y: bind(positioning.relative('#name').bottom(-4)),
    count: bind(function() {
      return obj.station && obj.station.available_bike;
    }),
  }));

  var park_status = bg.add(statusbox({ 
    id: '#parking',
    icon: loadimage('assets/img/icon_parking.png'),
    x: bind(positioning.prev.right()), 
    y: bind(positioning.prev.top()),
    count: bind(function() {
      return obj.station && obj.station.available_spaces;
    }),
  }));

  var report_button = bg.add(button({
    background: null,
    id: '#report',
    x: bind(function() { return bike_status.x; }),
    y: bind(positioning.relative('#parking').bottom(4)),
    text: 'Report',
    image: loadimage('assets/img/button.png'),
    color: 'white',
    height: 40,
    width: 102,
    size: 14,
  }));

  var fav_button = bg.add(button({
    id: '#fav',
    background: null,
    x: bind(positioning.relative('#report').right(-1)),
    y: bind(positioning.relative('#report').top()),
    image: loadimage('assets/img/button_fav.png'),
    width: 43,
    height: 40,
  }));

  var nav_button = bg.add(button({
    id: '#nav',
    background: null,
    x: bind(positioning.prev.right(-1)),
    y: bind(positioning.prev.top()),
    image: loadimage('assets/img/button.png'),
    height: 40,
    text: 'Navigate',
    color: 'white',
    size: 14,
  }));

  report_button.on('click', function() {
    obj.emit('report', obj.station);
  });

  fav_button.on('click', function() {
    obj.emit('fav', obj.station);
  });

  nav_button.on('click', function() {
    obj.emit('nav', obj.station);
  });

  return obj;
};
