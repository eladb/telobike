var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');
var animate = uijs.animation;
var positioning = uijs.positioning;
var image = require('uijs-controls').image;
var loadimage = uijs.util.loadimage;
var label = require('uijs-controls').label;
var button = require('uijs-controls').button;
var bind = uijs.bind;

module.exports = function(options) {

  //TODO: we can probably save quite a few binds if we use positioning more stinchly. 
  //      If we have perf issues, we should try it.

  function statusbox(options) {
    var obj = box(defaults(options, {
      width: 121, height: 58,
      count: 4,
      icon: loadimage('assets/img/icon_parking.png'),
      status: bind(obj, 'status', function() {
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
      image: bind(background_image, 'image', function() { return backgrounds[obj.status]; }),
      width: 121, height: 58,
    }));

    var icon_image = obj.add(image({
      image: bind(icon_image, 'image', function() { return obj.icon; }),
      width: 121/2, height: 58,
      x: 1, y: 1,
    }));

    var count_label = obj.add(label({
      text: bind(count_label, 'text', function() { return obj.count; }),
      color: 'white',
      size: 40,
      font: 'Helvetica',
      x: bind(count_label, 'x', positioning.prev.right()), 
      y: bind(count_label, 'y',positioning.prev.top(5)),
      width: 121/2-5,
    }));

    return obj;
  }

  var obj = box(defaults(options, {
    width: 276, height: 167,
    station: {
      name: '108 Rotchild Ave.',
      available_bike: 4,
      available_spaces: 2,
    },
  }));

  var bg = obj.add(image({
    x: 0, y: -6, width: 276, height: 167,
    image: loadimage('assets/img/panel.png'),
  }));

  var name_label = bg.add(label({
    id: '#name',
    x: 10, 
    width: bind(name_label, 'width', positioning.parent.width(-20)),
    y: 10, 
    height: 35,
    size: 20,
    color: 'white',
    shadow: true,
    text: bind(name_label, 'text', function() {
      return obj.station && obj.station.name;
    }),
  }));

  var bike_status = bg.add(statusbox({ 
    id: '#bicycle',
    icon: loadimage('assets/img/icon_bike.png'),
    x: 15, 
    y: bind(bike_status, 'y', positioning.relative('#name').bottom(-4)),
    count: bind(bike_status, 'count', function() {
      return obj.station && obj.station.available_bike;
    }),
  }));

  var park_status = bg.add(statusbox({ 
    id: '#parking',
    icon: loadimage('assets/img/icon_parking.png'),
    x: bind(park_status, 'x', positioning.prev.right()), 
    y: bind(park_status, 'y', positioning.prev.top()),
    count: bind(park_status, 'count', function() {
      return obj.station && obj.station.available_spaces;
    }),
  }));

  var report_button = bg.add(button({
    id: '#report',
    x: bind(report_button, 'x', function() { return bike_status.x; }),
    y: bind(report_button, 'y', positioning.relative('#parking').bottom(4)),
    text: 'Report',
  }));

  var fav_button = bg.add(button({
    id: '#fav',
    x: bind(fav_button, 'x', positioning.relative('#report').right(-1)),
    y: bind(fav_button, 'y', positioning.relative('#report').top()),
    image: loadimage('assets/img/button_fav.png'),
    width: 43,
    height: 40,
  }));

  var nav_button = bg.add(button({
    id: '#nav',
    x: bind(nav_button, 'x', positioning.prev.right(-1)),
    y: bind(nav_button, 'y', positioning.prev.top()),
    text: 'Navigate',
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