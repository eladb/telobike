var uijs = require('uijs');
var scroller = uijs.scroller;
var util = uijs.util;
var box = uijs.box;
var controls = require('uijs-controls');
var telobikeListItem = require('./telobikeListItem');
var listview = controls.listview;
var bind = uijs.bind;
var util = uijs.util;
var defaults = util.defaults;
var searchBar = controls.searchBar;

module.exports = function(options) {   
  var obj = listview(defaults(options, {
    items:[],
    onBindBoxItem: telobikeListItem,
    itemHeight:68,
    filterCondition: function(data,value){
      return (data.name_en.toLowerCase().indexOf(value.toLowerCase()) != -1); 
    },
    searchBar:searchBar({ height:40, }),
    model: null,
    invalidators: [ 'model' ],
  }));

  var stations;

  obj.watch('model', function(val) {
    if (!obj.model) return;
    obj.model.on('update', function() {
      console.log('model updated (' + obj.model.stations.length + ' stations)');
      stations = obj.model.stations.sort(function(a,b) {
        if (!a.distance || !b.distance) return 0;
        return parseInt(a.distance) - parseInt(b.distance);
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
    
   
  }, true);

  return obj;
};
