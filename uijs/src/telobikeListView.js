var uijs = require('uijs');
var scroller = uijs.scroller;
var box = uijs.box;
var controls = require('uijs-controls');
var telobikeListItem = require('./telobikeListItem');
var listview = controls.listview;
var bind = uijs.bind;
var util = uijs.util;
var defaults = util.defaults;

module.exports = function(options) {
  // var x = box(options);
  // x.ondraw = function(ctx) {
  //   ctx.fillStyle = 'red';
  //   ctx.fillRect(0, 0, this.width, this.height);
  // };
  // return x;

  var obj = listview(defaults(options, {
    model: null,
    onBindBoxItem: telobikeListItem,
    itemHeight: 68,
    items: [],
    invalidators: [ 'model' ],
    clip: true,
  }));

  obj.watch('model', function(val) {
    if (!obj.model) return;
    obj.model.on('update', function() {
      console.log('model updated (' + obj.model.stations.length + ' stations)');
      obj.items = obj.model.stations.sort(function(a,b) {
        if (!a.distance || !b.distance) return 0;
        return parseInt(a.distance) - parseInt(b.distance);
      });
    });
  });

  return obj;
};
