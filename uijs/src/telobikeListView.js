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
    itemHeight:68
  });

  var model = require('./model').createModel();

  model.on('update', function() {
    obj.items = model.stations.sort(function(a,b){
      if(!a.distance || !b.distance)
      {
        return 0;
      }
      return (parseInt(a.distance) - parseInt(b.distance));
    });
  });
  
  obj.on('click',function(data){
    data.select = true;
  })

  return obj;
}

module.exports = stripes();