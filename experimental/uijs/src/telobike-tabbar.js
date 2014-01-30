var tabbar = require('./tabbar');
var uijs = require('uijs');
var defaults = uijs.util.defaults;

module.exports = function(options) {
  var obj = tabbar(defaults(options, {
    selected: 'list',
    tabs: {
      list: {
        icon: 'assets/img/tabbar_list.png',
        title: 'List',
      },
      map: {
        icon: 'assets/img/tabbar_map.png',
        title: 'Map',
      },
      timer: {
        icon: 'assets/img/tabbar_alarm.png',
        title: 'Timer',
      },
      settings: {
        icon: 'assets/img/tabbar_settings.png',
        title: 'Settings',
      }
    },
  }));

  return obj;
};