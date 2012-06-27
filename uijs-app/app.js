var UI = require('uijs');
var constant = UI.util.constant;
var derive = UI.util.derive;
var animate = UI.animation;
var defaults = UI.util.defaults;
var override = UI.util.override;
var $x = require('xui');
var data = require('./lib/data');
var loadimage = UI.util.loadimage;

var app = UI.app({
  layout: UI.layouts.dock({ stretch: constant(true) }),
});

function placeholder(options) {
  var obj = UI.view(defaults(options, {
    // alpha: constant(0.5),
    fillStyle: constant('rgba(100, 100, 100, 0.1)'),
    strokeStyle: constant('black'),
    textFillStyle: constant('909090'),
    font: constant('italic 12pt Helvetica')
  }));

  return obj;
}

var navbar = placeholder({
  height: constant(44),
  dockStyle: constant('top'),
  width: app.width,
  text: constant('navbar'),
});

var tabbar = placeholder({
  height: constant(50),
  dockStyle: constant('bottom'),
  width: app.width,
  text: constant('tabbar'),
});

app.add(navbar);
app.add(tabbar);

var content = UI.view({
  alpha: constant(1.0),
  dockStyle: constant('fill'),
  fillStyle: constant('#404040'),
  layout: UI.layouts.none(),
});

app.add(content);

var list = UI.view({
  alpha: constant(1.0),
  dockStyle: constant('fill'),
  fillStyle: constant('white'),
  layout: UI.layouts.stack({
    spacing: constant(1),
    stretch: constant(true),
  }),
});

content.add(list);

list.x = constant(0);
list.y = constant(0);
list.width = content.width;
list.height = function() {
  return content.height();
};
//   return content.height() + -1*list.y();
// };
// list.y = UI.animation(0, -2000, { duration: constant(10000) });

list.on('touchstart', function() {
  alert('hey');
});


function listitem(options) {
  var def = {
    passthrough: constant(true),
    strokeStyle: null,
    shadowColor: constant('red'),
    shadowBlur: constant(0),
    width: app.width,
    height: constant(62),
    radius: constant(0),
    layout: UI.layouts.dock({
      padding: constant(10),
      spacing: constant(10),
    }),
    highlighted: {
      fillStyle: constant('#aaaaaa'),
    },
    children: [
      UI.image({
        width: function() { return 46; },
        height: function() { return 46; },
        dockStyle: constant('right'),
        image: loadimage(options.icon),
      }),
      UI.view({
        dockStyle: constant('top'),
        font: constant('bold 16pt arial,sans-serif'),
        height: constant(24),
        textAlign: constant('right'),
        text: options.title,
      }),
      UI.view({
        dockStyle: constant('bottom'),
        font: constant('12pt arial,sans-serif'),
        textAlign: constant('right'),
        text: options.subtitle,
        height: constant(20),
        textFillStyle: constant('gray'),
      }),
    ],
    text: null,
  };

  var obj = UI.button(defaults(options, def));

  var base_ondraw = obj.ondraw;
  obj.ondraw = function(ctx) {
    var self = this;
    base_ondraw.call(self, ctx);
    ctx.beginPath();
    ctx.moveTo(0, self.height());
    ctx.lineTo(self.width(), self.height());
    ctx.closePath();
    ctx.strokeStyle = '#eeeeee';
    ctx.stroke();
  };

  return obj;
}

UI.listitem = listitem;

current_location = false;

function load_stations(stations) {
  stations = stations
    .map(function(s) {
      s.online = !!s.last_update;
      s.active = !s.online || s.available_bike > 0 || s.available_spaces > 0;
      s.status = determine_status(s);
      s.subtitle =  ' אופניים ' + s.available_bike + ' חניות ' + s.available_spaces;
      // s.last_update_label = prettyDate(s.last_update_time);
      // if (current_location) {
      //   var d = calculate_distance([ s.latitude, s.longitude ], current_location);
      //   var dl = d < 1.0 ? (d * 1000).toFixed(1) + 'm' : d.toFixed(1) + 'km';
      //   s.distance = d;
      //   s.distance_label = dl;
      // }

      return s;
    });

  for (var i = 0; i < 20; ++i) {
    var station = stations[i];
    list.add(UI.listitem({
      title: constant(station.name),
      subtitle: constant(station.subtitle),
      icon: constant('dist/assets/img/list_' + station.status + '.png'),
    }));
  }    
}

x$(null).xhr('http://telobike.citylifeapps.com/stations', {
  async: true,
  callback: function(x) {
    load_stations(JSON.parse(this.responseText));
  },
});

load_stations(data);

var MARGINAL = 3;

function determine_status(station) {
  if (!station.online) return 'unknown';
  if (!station.active) return 'inactive';
  if (station.available_bike === 0) return 'empty';
  if (station.available_spaces === 0) return 'full';
  if (station.available_bike <= MARGINAL) return 'hempty';
  if (station.available_spaces <= MARGINAL) return 'hfull';
  return 'okay';
}

module.exports = app;
