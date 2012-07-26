var uijs = require('uijs');
var box = uijs.box;
var util = uijs.util;
var positioning = uijs.positioning;
var controls = require('uijs-controls');
var button = controls.button;
var image = controls.image;
var label = controls.label;

module.exports = function(data) {
  var obj = button({
    //width:function(){return this.root().width;},
    //height:68,
  });

  //temp
  obj.width = function(){return obj.root().width;};
  obj.height = 67;

  var img = image({
    image: util.loadimage(data.list_image),
    x:10,
    y:10,
    adaptSizeAccordingToImage:true,
  });

  var location = label({
    text:data.name_en,
    y:positioning.prev.top(5),
    x:positioning.prev.right(10),
    size:14,
    width:100,
    bold:true,
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
  });

  var arrow = image({
    image: util.loadimage('assets/img/arrow.jpg'),
    adaptSizeAccordingToImage:true,
    y:20,
    x:positioning.parent.right(-40),
  });

  var distance = label({
    text:data.distance || '100m',
    y:positioning.prev.bottom(5),
    x:positioning.prev.left(-10),
    size:10,
    color:'gray',
    width:40,
  });

  obj.add(img);
  obj.add(location);
  obj.add(bikeStatus);
  obj.add(parkingStatus);
  obj.add(arrow);
  obj.add(distance);

  return obj; 
};
  
