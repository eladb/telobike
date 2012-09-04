var uijs = require('uijs');
var defaults = uijs.util.defaults;
var nativebox = require('./nativebox');
var positioning = uijs.positioning;
var bind = uijs.bind;

module.exports = function(options) {
  var obj = nativebox(defaults(options, {
    type: 'UIJSTabBar',
    tabs: [],
    width: bind(positioning.parent.width()),
    height: 50,
    x: 0,
    y: bind(positioning.parent.height(-50)),
    selected: null,
  }));

  obj.on('init', function(native_view) {
    var self = this;

    self.watch('tabs', function() {
      var tabs = Object.keys(self.tabs).map(function(tabid) {
        var t = self.tabs[tabid];
        t._id = tabid;
        return t;
      });

      native_view.call('set_tabs', { tabs: tabs });
      native_view.call('select_tab', { key: self.selected });
    });

    obj.watch('selected', function() {
      if (!watch_selected) return;
      self.native.call('select_tab', { key: self.selected });
    });

  });

  var watch_selected = true;

  obj.on('_selected', function(p) {
    watch_selected = false;
    this.selected = p.id;
    watch_selected = true;
  });

  return obj;
};