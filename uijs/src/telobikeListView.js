var uijs = require('uijs');
var scroller = uijs.scroller;
var box = uijs.box;
var controls = require('uijs-controls');
var telobikeListItem = require('./telobikeListItem');
var listview = controls.listview;
var bind = uijs.bind;

function stripes() {
  var obj = listview({
    items:[],
    onBindBoxItem: telobikeListItem,
    itemHeight:68,
  });

  var model = require('./model').createModel();

  model.on('update', function() {
    obj.items = model.stations;
  });
  
  return obj;
}

module.exports = stripes();