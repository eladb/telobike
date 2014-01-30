function createRouter(options) {
  var obj = box();

  var pages = {};
  var stack = [];

  obj.page = function(path, box) {
    pages[path] = box;
    
    // full screen, hidden
    box.x = 0;
    box.y = 0;
    box.width = positioning.parent.width();
    box.height = positioning.parent.height();
    box.visible = false;

    obj.children.push(box);
    return box;
  };

  obj.navigate = function(path, callback) {
    var prev = stack[stack.length - 1];
    var curr = pages[path];

    var onshow = next.onshow || noop;
    return onshow(prev, curr, function() {
      stack.push(curr);
      return callback(curr);
    })
  };

  obj.pop = function(callback) {
    var curr = stack.pop();
    var prev = stack[stack.length - 1];

    var onhide = next.onhide || noop;
    return onhide(prev, curr, function() {
      return callback(curr);
    })
  };

  function noop(prev, curr, cb) {
    return cb();
  }

  return obj;
}