var uijs = require('uijs');
var defaults = uijs.util.defaults;
var nativebox = require('./nativebox');
var positioning = uijs.positioning;
var bind = uijs.bind;

module.exports = function(options) {
  var obj = nativebox(defaults(options, {
    type: 'UIJSNavigationBar',
    title: 'Hello',
    width: bind(positioning.parent.width()),
    height: 44,
    x: 0,
    y: 0,
    invalidators: [ 'title' ],
  }));

  obj.clear_items = function() {
    obj.native.call('clear_items');
  };

  obj.push_item = function(item, options) {
    obj.native.call('push_item', {
      item: item,
      options: options
    });
  };

  obj.pop_item = function(options) {
    obj.native.call('pop_item', options);
  };

  return obj;
};