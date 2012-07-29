var uijs = require('uijs');
var box = uijs.box;
var util = uijs.util;
var positioning = uijs.positioning;
var controls = require('uijs-controls');
var button = controls.button;
var image = controls.image;
var label = controls.label;
var rect = controls.rect;

module.exports = function(boxItem) {
  var backround = rect({
    width : boxItem.width,
    height : boxItem.height - 1,
    color: function(){
      return (boxItem.data.clicked) ? 'gray' : 'white';
     },
     alpha:function(){
      return (boxItem.data.clicked) ? 0.5 : 1;
     },
  });

  var img = image({
    image: function(){ return boxItem.data.list_image;},
    x:10,
    y:10,
  });

  var location = label({
    text:function() { return boxItem.data.name_en; },
    y:positioning.prev.top(5),
    x:positioning.prev.right(10),
    size:14,
    width:100,
    bold:true,
  });

  var bikeStatus = label({
    text:function(){return "bikes: " +  boxItem.data.available_bike;},
    color:function(){
      if(boxItem.data.status === 'empty') return 'red';
      if(boxItem.data.status === 'hempty') return 'orange';
      return 'black';
    },
    y:positioning.prev.bottom(5),
    x:positioning.prev.left(),
    size:14,
    width:50,
  });

  var parkingStatus = label({
    text:function(){return "parking: " +  boxItem.data.available_spaces; },
    color:function(){
      if(boxItem.data.status === 'full') return 'red';
      if(boxItem.data.status === 'hfull') return 'orange';
      return 'black';
    },
    y:positioning.prev.top(),
    x:positioning.prev.right(20),
    size:14,
    width:50,
  });

  var whiteArrowImage = util.loadimage('assets/img/white_arrow.png');
  var grayArrowImage = util.loadimage('assets/img/arrow.png');

  var arrow = image({
    image: function(){
      return (boxItem.data.clicked) ? whiteArrowImage : grayArrowImage;
    },
    y:20,
    x:positioning.parent.right(-40),
  });

  var distance = label({
    text:function(){return boxItem.data.distance || '100m';},
    y:positioning.prev.bottom(5),
    x:positioning.prev.left(-10),
    size:10,
    color:'gray',
    width:40,
  });

  var seperator = rect({
    height: 1,
    x:0,
    y:boxItem.height - 1,
    width:boxItem.width,
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
  
