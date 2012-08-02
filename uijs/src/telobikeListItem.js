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
  var img = image({
    image: bind(img, 'image', function(){ return boxItem.data.list_image;}),
    x:10,
    y:10,
    width:47,
    height:47,
  });

  var textLocationStart = 27;
    
  var location = label({
    text:bind(location, 'text', function() { return boxItem.data.name_en; }),
    x:67,
    y:textLocationStart,
    size:14,
    width:100,
    height:16.8,
    bold:true,
  });

  var bikeStatus = label({
    text:bind(bikeStatus, 'text', function(){return "bikes: " +  boxItem.data.available_bike;}),
    color:bind(bikeStatus, 'color', function(){
      if(boxItem.data.status === 'empty') return 'red';
      if(boxItem.data.status === 'hempty') return 'orange';
      return 'black';
    }),
    x:67,
    y:textLocationStart + 20,
    size:14,
    width:50,
    height:16.8,
  });

  var parkingStatus = label({
    text:bind(parkingStatus, 'text', function(){return "parking: " +  boxItem.data.available_spaces; }),
    color:bind(parkingStatus, 'color', function(){
      if(boxItem.data.status === 'full') return 'red';
      if(boxItem.data.status === 'hfull') return 'orange';
      return 'black';
    }),
    x:167,
    y:textLocationStart + 20,
    size:14,
    width:50,
    height:16.8,
  });

  var whiteArrowImage = util.loadimage('assets/img/white_arrow.png');
  var grayArrowImage = util.loadimage('assets/img/arrow.png');

  var arrow = image({
    image: grayArrowImage,
    x: boxItem.width - 45,
    y:20,
    width:20,
    height:25,
  });

  var distance = label({
    text:bind(distance, 'text', function(){return boxItem.data.distance || '100m';}),
    x:boxItem.width - 50,
    y:textLocationStart + 30,
    size:10,
    width:40,
    height:12,
  });

  var seperator = rect({
    x:0,
    y:boxItem.height - 1,
    width:boxItem.width,
    height:1,
    color:'gray',
  });

  boxItem.add(img);
  boxItem.add(location);
  boxItem.add(bikeStatus);
  boxItem.add(parkingStatus);
  boxItem.add(arrow);
  boxItem.add(distance);
  boxItem.add(seperator);
};
  
