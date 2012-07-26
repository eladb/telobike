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

module.exports = function(options) {

  function statusbox(options) {
    var obj = box(defaults(options, {
      width: 121, height: 58,
      count: function() { return 4; },
      icon: loadimage('assets/img/icon_parking.png'),
      status: function() {
        if (this.count === 0) return 'red';
        if (this.count <= 3) return 'yellow';
        else return 'green';
      },
    }));

    var backgrounds = {
      green: loadimage('assets/img/greenbox.png'),
      red: loadimage('assets/img/redbox.png'),
      yellow: loadimage('assets/img/yellowbox.png'),
    };

    var background_image = obj.add(image({
      image: function() { return backgrounds[obj.status](); },
      width: 121, height: 58,
    }));

    var icon_image = obj.add(image({
      image: function() { return obj.icon; },
      width: 121/2, height: 58,
      x: 1, y: 1,
    }));

    var count_label = obj.add(label({
      text: function() { return obj.count; },
      color: 'white',
      size: 40,
      font: 'Helvetica',
      x: positioning.prev.right(), y: positioning.prev.top(5),
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
    x: 10, width: positioning.parent.width(-20),
    y: 10, height: 35,
    size: 20,
    color: 'white',
    shadow: true,
    text: function() {
      return obj.station && obj.station.name;
    }
  }));

  var bike_status = bg.add(statusbox({ 
    id: '#bicycle',
    icon: loadimage('assets/img/icon_bike.png'),
    x: 15, y: positioning.relative('#name').bottom(-4),
    count: function() {
      return obj.station && obj.station.available_bike;
    },
  }));

  var park_status = bg.add(statusbox({ 
    id: '#parking',
    icon: loadimage('assets/img/icon_parking.png'),
    x: positioning.prev.right(), y: positioning.prev.top(),
    count: function() {
      return obj.station && obj.station.available_spaces;
    },
  }));

  var report_button = bg.add(button({
    id: '#report',
    x: function() { return bike_status.x; },
    y: positioning.relative('#parking').bottom(4),
    text: 'Report',
  }));

  var fav_button = bg.add(button({
    id: '#fav',
    x: positioning.relative('#report').right(-1),
    y: positioning.relative('#report').top(),
    image: loadimage('assets/img/button_fav.png'),
    width: 43,
    height: 40,
  }));

  var nav_button = bg.add(button({
    id: '#nav',
    x: positioning.prev.right(-1),
    y: positioning.prev.top(),
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