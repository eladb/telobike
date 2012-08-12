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
    color: bind(backround, 'color', function(){ return (boxItem.data.select || boxItem.highlight) ? 'gray' : 'white'; }),
    alpha: bind(backround, 'alpha', function(){ return (boxItem.data.select || boxItem.highlight) ? 0.5 : 1; }),
  });


  var images = {};

  var img = image({
    image: bind(img, 'image', function(){ 
      if (!images[boxItem.data.list_image]) {
        images[boxItem.data.list_image] = util.loadimage(boxItem.data.list_image);
      }
      return images[boxItem.data.list_image];
    }),
    x:10,
    y:10,
    width:47,
    height:47,
  });

  var textLocationStart = 13;
    
  var location = label({
    text:bind(location, 'text', function() { return boxItem.data.name_en; }),
    x:67,
    y:textLocationStart,
    size:14,
    width:boxItem.width - 45 - 67 - 5,
    height:14,
    bold:true,
    align: 'left',
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
    width:100,
    height:14,
    align: 'left',
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
    width:boxItem.width - 45 - 67,
    height:14,
    align: 'left',
  });

  var whiteArrowImage = util.loadimage('assets/img/white_arrow.png');
  var grayArrowImage = util.loadimage('assets/img/arrow.png');

  var arrow = image({
    image: bind(arrow, 'image', function(){ return (boxItem.data.select || boxItem.highlight) ? whiteArrowImage : grayArrowImage;}),
    x: boxItem.width - 45,
    y:20,
    width:20,
    height:25,
  });

  var distance = label({
    text:bind(distance, 'text', function(){return (boxItem.data.distance) ? 
      ((boxItem.data.distance >= 1000) ? (boxItem.data.distance/1000).toFixed(1) +' km' :  boxItem.data.distance +' m') : 
      'undefined'; }),
    x:boxItem.width - 50,
    y:textLocationStart + 30,
    size:10,
    width:50,
    height:10,
    color:'gray',
    align: 'left',
  });

  var seperator = rect({
    x:0,
    y:boxItem.height - 1,
    width:boxItem.width,
    height:1,
    color:'gray',
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
  
