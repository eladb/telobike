var uijs = require('uijs');
var scroller = uijs.scroller;
var util = uijs.util;
var box = uijs.box;
var controls = require('uijs-controls');
var telobikeListItem = require('./telobikeListItem');
var listview = controls.listview;
var bind = uijs.bind;
var searchBar = controls.searchBar;

function stripes() {
    
  var obj = listview({   
    items:[],
    onBindBoxItem: telobikeListItem,
    itemHeight:68,
    filterCondition: function(data,value){
      return (data.name_en.toLowerCase().indexOf(value.toLowerCase()) != -1); 
    },
    searchBar:searchBar({
      height:40,
    }),
  });

  var model = require('./model').createModel();

  model.on('update', function() {
    var stations = model.stations.sort(function(a,b){
      if(!a.distance || !b.distance)
      {
        return 0;
      }
      return (parseInt(a.distance) - parseInt(b.distance));
    });
    
    stations.unshift({
      city: 'tlv',
      name_en: 'Current Position',
      status: 'okay',
      list_image: 'assets/img/MyLocation.png',
      distance: 0, 
    });

    obj.items = stations;
  });
  
  obj.on('click',function(data){
    data.select = true;
  })

  return obj;
}

module.exports = stripes();