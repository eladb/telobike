var uijs = require('uijs');
var box = uijs.box;
var util = uijs.util;
var controls = require('uijs-controls');
var button = controls.button;
var image = controls.image;
var label = controls.label;
var rect = controls.rect;
var bind = uijs.bind;

module.exports = function(boxItem) {
  
  boxItem.is_simple_container = true;

  var backround = rect({
    width : boxItem.width,
    height : boxItem.height - 1,
    color: bind(function () { return (boxItem.data.select || boxItem.highlight) ? 'gray' : 'white'; }),
    alpha: bind(function () { return (boxItem.data.select || boxItem.highlight) ? 0.5 : null; }),
  });

  var img = image({
    image: bind(function() { return util.loadimage(boxItem.data.list_image); }),
    x:10,
    y:10,
    width:50,
    height:50,
  });

  var arrow = image({
    image: bind(function() {
      return (boxItem.data.select || boxItem.highlight) ? util.loadimage('assets/img/white_arrow.png') : util.loadimage('assets/img/arrow.png'); 
    }),
    x: boxItem.width - 45,
    y:20,
    width:20,
    height:25
  });

  var textLocationStart = 17;

  var location = label({
    text: bind(function() { return boxItem.data.name_en; }),
    x: 67,
    y: textLocationStart,
    size: 14,
    width: boxItem.width - 45 - 67 - 5,
    height: bind(function(){
      return boxItem.data.name_en !== 'Current Position' ?  20 : 26;
    }),
    bold: true,
    align: 'left',
  });

  var bikeStatus = label({
    text: bind(function(){ return "bikes: " +  boxItem.data.available_bike;}),
    color: bind(function(){
      if(boxItem.data.status === 'empty') return 'red';
      if(boxItem.data.status === 'hempty') return 'orange';
      return 'black';
    }),
    x: 67,
    y: textLocationStart + 20,
    size: 14,
    width: 100,
    height: 20,
    align: 'left',
    visible: bind(function(){ return boxItem.data.name_en !== 'Current Position'; }),
  });

  var parkingStatus = label({
    text: bind(function(){return "parking: " +  boxItem.data.available_spaces; }),
    color: bind(function(){
      if(boxItem.data.status === 'full') return 'red';
      if(boxItem.data.status === 'hfull') return 'orange';
      return 'black';
    }),
    x: 167,
    y: textLocationStart + 20,
    size: 14,
    width: boxItem.width - 45 - 67,
    height: 20,
    align: 'left',
    visible: bind(function(){ return boxItem.data.name_en !== 'Current Position'; }),
  });

  var arrow = image({
    image: bind(function(){ return (boxItem.data.select || boxItem.highlight) ? images['assets/img/white_arrow.png'] : images['assets/img/arrow.png'];}),
    x: boxItem.width - 45,
    y: 20,
    width: 20,
    height: 25,
  });

  var distance = label({
    text: bind(function(){
      return (typeof boxItem.data.distance !== undefined) ? 
      ((boxItem.data.distance >= 1000) ? (boxItem.data.distance/1000).toFixed(1) +' km' :  boxItem.data.distance +' m') : 
      'undefined'; }),
    x: boxItem.width - 50,
    y: textLocationStart + 30,
    size: 10,
    width: 50,
    height: 15,
    color: 'gray',
    align: 'left',
  });

  var seperator = rect({
    x: 0,
    y: boxItem.height - 1,
    width: boxItem.width,
    height: 1,
    color: 'gray',
  });

  boxItem.add(backround);
  boxItem.add(img);
  boxItem.add(location);
  boxItem.add(bikeStatus);
  boxItem.add(parkingStatus);
  boxItem.add(arrow);
  boxItem.add(distance);
  boxItem.add(seperator);

};
  
