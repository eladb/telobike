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
  
  var backround = rect({
    width : boxItem.width,
    height : boxItem.height - 1,
    visible: bind(function () { return (boxItem.data.select || boxItem.highlight) ? true : false; }),
    color: 'gray',
    alpha: 0.5,
  });


  var images = {};
  images['assets/img/list_empty.png'] = util.loadimage('assets/img/list_empty.png');
  images['assets/img/list_hempty.png'] = util.loadimage('assets/img/list_hempty.png');
  images['assets/img/list_full.png'] = util.loadimage('assets/img/list_full.png');
  images['assets/img/list_hfull.png'] = util.loadimage('assets/img/list_hfull.png');
  images['assets/img/list_okay.png'] = util.loadimage('assets/img/list_okay.png');
  images['assets/img/MyLocation.png'] = util.loadimage('assets/img/MyLocation.png');
  images['assets/img/white_arrow.png'] = util.loadimage('assets/img/white_arrow.png');
  images['assets/img/arrow.png'] = util.loadimage('assets/img/arrow.png');

  var img = image({
    image: bind(img, 'image', function(){ 
      return images[boxItem.data.list_image];
    }),
    x:10,
    y:10,
    width:50,
    height:50,
  });

  var textLocationStart = 17;


  var location = label({
    text: bind(location, 'text', function() { return boxItem.data.name_en; }),
    x: 67,
    y: textLocationStart,
    size: 14,
    width: boxItem.width - 45 - 67 - 5,
    height: bind(location, 'height', function(){
      return boxItem.data.name_en != 'Current Position' ?  20 : 40;
    }),
    bold: bind(location, 'bold', function(){ return (boxItem.data.name_en != 'Current Position'); }),
    align: 'left',
  });

  var bikeStatus = label({
    text: bind(bikeStatus, 'text', function(){ return "bikes: " +  boxItem.data.available_bike;}),
    color: bind(bikeStatus, 'color', function(){
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
    visible: bind(function(){ return boxItem.data.name_en != 'Current Position'; }),
  });

  var parkingStatus = label({
    text: bind(parkingStatus, 'text', function(){return "parking: " +  boxItem.data.available_spaces; }),
    color: bind(parkingStatus, 'color', function(){
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
    visible: bind(function(){ return boxItem.data.name_en != 'Current Position'; }),
  });

  var arrow = image({
    image: bind(arrow, 'image', function(){ return (boxItem.data.select || boxItem.highlight) ? images['assets/img/white_arrow.png'] : images['assets/img/arrow.png'];}),
    x: boxItem.width - 45,
    y: 20,
    width: 20,
    height: 25,
  });

  var distance = label({
    text: bind(distance, 'text', function(){
      return (boxItem.data.distance) ? 
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
  
