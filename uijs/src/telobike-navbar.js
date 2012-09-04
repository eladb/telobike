var navbar = require('./navbar');
var uijs = require('uijs');
var defaults = uijs.util.defaults;
var bind = uijs.bind;
var positioning = uijs.positioning;
var animate = uijs.animation;
var box = uijs.box;

module.exports = function(options) {
  var obj = box(defaults(options, {
    x: 0, y: 0, width: bind(positioning.parent.width()), height: bind(positioning.parent.height())
  }));

  var stack = [];

  var nav = obj.add(navbar({
    id: 'nav-bar',
  }));
  
  var content = obj.add(box({
    id: 'nav-content',
    x: 0, y: bind(function() { return nav.height; }), 
    width: bind(positioning.parent.width()),
    height: bind(function() { return this.parent.height - nav.height; }),
    clip: true,
  }));

  obj.current = function() {
    if (stack.length === 0) return null;
    return stack[stack.length - 1];
  };

  obj.push_box = function(box, options) {
    var self = this;
    options = options || {};
    var animated = 'animated' in options ? options.animated : true;
    
    var curr = self.current();
    box.bind('width', positioning.parent.width());
    box.bind('height', positioning.parent.height());
    box.y = 0;

    // this is the first box, just place it in the content area
    if (!curr) {
      box.x = 0;
    }
    else {
      box.x = bind(animate(function() { return this.parent.width; }, 0));
      curr.x = bind(animate(0, function() { return -this.parent.width; }));
    }

    content.add(box);
    stack.push(box);
    nav.push_item({ title: box.title });
  };

  obj.pop_box = function() {
    nav.pop_item();
    nav.emit('pop');
  };

  nav.on('init', function() {
    obj.emit('init');
  });

  nav.on('pop', function() {
    var self = this;
    console.log('pop!');
    var box = stack.pop();
    console.log('going right from 0 -> w:' + box.title);
    var prev = self.current();
    if (prev) console.log('going right from -w -> 0:' + prev);

    // if (prev) {
    //   prev.x = bind(animate(function() { return -this.parent.width; }, 0));
    // }

    // box.x = bind(animate(0, function() { return this.parent.width; }));
  });

  return obj;
};