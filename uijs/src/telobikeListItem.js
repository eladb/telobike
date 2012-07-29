var uijs = require('uijs');
var box = uijs.box;
var util = uijs.util;
var positioning = uijs.positioning;
var controls = require('uijs-controls');
var button = controls.button;
var image = controls.image;
var label = controls.label;
var rect = controls.rect;

module.exports = function(data) {
  var obj = rect({
    width : function(){return obj.root().width;},
    height : 67,
    color: function(){
      return (data.clicked) ? 'gray' : 'white';
     },
     alpha:function(){
      return (data.clicked) ? 0.5 : 1;
     },
  });

  var img = image({
    image: util.loadimage(data.list_image),
    x:10,
    y:10,
    adaptSizeAccordingToImage:true,
    alpha: 1,
  });

  var location = label({
    text:data.name_en,
    y:positioning.prev.top(5),
    x:positioning.prev.right(10),
    size:14,
    width:100,
    bold:true,
    alpha: 1,
  });

  var bikeStatus = label({
    text:"bikes: " +  data.available_bike,
    color:function(){
      if(data.status === 'empty') return 'red';
      if(data.status === 'hempty') return 'orange';
      return 'black';
    },
    y:positioning.prev.bottom(5),
    x:positioning.prev.left(),
    size:14,
    width:50,
    alpha: 1,
  });

  var parkingStatus = label({
    text:"parking: " +  data.available_spaces,
    color:function(){
      if(data.status === 'full') return 'red';
      if(data.status === 'hfull') return 'orange';
      return 'black';
    },
    y:positioning.prev.top(),
    x:positioning.prev.right(20),
    size:14,
    width:50,
    alpha: 1,
  });

  var arrow = image({
    image: function(){
      return (data.clicked) ? util.loadimage('assets/img/white_arrow.png'):
                             util.loadimage('assets/img/arrow.png');
    },
    y:20,
    x:positioning.parent.right(-40),
    alpha: 1,
  });

  var distance = label({
    text:data.distance || '100m',
    y:positioning.prev.bottom(5),
    x:positioning.prev.left(-10),
    size:10,
    color:'gray',
    width:40,
    alpha: 1,
  });

  obj.add(img);
  obj.add(location);
  obj.add(bikeStatus);
  obj.add(parkingStatus);
  obj.add(arrow);
  obj.add(distance);

  return obj; 
};
  
