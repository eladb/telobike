(function(){var require = function (file, cwd) {
    var resolved = require.resolve(file, cwd || '/');
    var mod = require.modules[resolved];
    if (!mod) throw new Error(
        'Failed to resolve module ' + file + ', tried ' + resolved
    );
    var cached = require.cache[resolved];
    var res = cached? cached.exports : mod();
    return res;
}

require.paths = [];
require.modules = {};
require.cache = {};
require.extensions = [".js",".coffee"];

require._core = {
    'assert': true,
    'events': true,
    'fs': true,
    'path': true,
    'vm': true
};

require.resolve = (function () {
    return function (x, cwd) {
        if (!cwd) cwd = '/';
        
        if (require._core[x]) return x;
        var path = require.modules.path();
        cwd = path.resolve('/', cwd);
        var y = cwd || '/';
        
        if (x.match(/^(?:\.\.?\/|\/)/)) {
            var m = loadAsFileSync(path.resolve(y, x))
                || loadAsDirectorySync(path.resolve(y, x));
            if (m) return m;
        }
        
        var n = loadNodeModulesSync(x, y);
        if (n) return n;
        
        throw new Error("Cannot find module '" + x + "'");
        
        function loadAsFileSync (x) {
            x = path.normalize(x);
            if (require.modules[x]) {
                return x;
            }
            
            for (var i = 0; i < require.extensions.length; i++) {
                var ext = require.extensions[i];
                if (require.modules[x + ext]) return x + ext;
            }
        }
        
        function loadAsDirectorySync (x) {
            x = x.replace(/\/+$/, '');
            var pkgfile = path.normalize(x + '/package.json');
            if (require.modules[pkgfile]) {
                var pkg = require.modules[pkgfile]();
                var b = pkg.browserify;
                if (typeof b === 'object' && b.main) {
                    var m = loadAsFileSync(path.resolve(x, b.main));
                    if (m) return m;
                }
                else if (typeof b === 'string') {
                    var m = loadAsFileSync(path.resolve(x, b));
                    if (m) return m;
                }
                else if (pkg.main) {
                    var m = loadAsFileSync(path.resolve(x, pkg.main));
                    if (m) return m;
                }
            }
            
            return loadAsFileSync(x + '/index');
        }
        
        function loadNodeModulesSync (x, start) {
            var dirs = nodeModulesPathsSync(start);
            for (var i = 0; i < dirs.length; i++) {
                var dir = dirs[i];
                var m = loadAsFileSync(dir + '/' + x);
                if (m) return m;
                var n = loadAsDirectorySync(dir + '/' + x);
                if (n) return n;
            }
            
            var m = loadAsFileSync(x);
            if (m) return m;
        }
        
        function nodeModulesPathsSync (start) {
            var parts;
            if (start === '/') parts = [ '' ];
            else parts = path.normalize(start).split('/');
            
            var dirs = [];
            for (var i = parts.length - 1; i >= 0; i--) {
                if (parts[i] === 'node_modules') continue;
                var dir = parts.slice(0, i + 1).join('/') + '/node_modules';
                dirs.push(dir);
            }
            
            return dirs;
        }
    };
})();

require.alias = function (from, to) {
    var path = require.modules.path();
    var res = null;
    try {
        res = require.resolve(from + '/package.json', '/');
    }
    catch (err) {
        res = require.resolve(from, '/');
    }
    var basedir = path.dirname(res);
    
    var keys = (Object.keys || function (obj) {
        var res = [];
        for (var key in obj) res.push(key);
        return res;
    })(require.modules);
    
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        if (key.slice(0, basedir.length + 1) === basedir + '/') {
            var f = key.slice(basedir.length);
            require.modules[to + f] = require.modules[basedir + f];
        }
        else if (key === basedir) {
            require.modules[to] = require.modules[basedir];
        }
    }
};

(function () {
    var process = {};
    
    require.define = function (filename, fn) {
        if (require.modules.__browserify_process) {
            process = require.modules.__browserify_process();
        }
        
        var dirname = require._core[filename]
            ? ''
            : require.modules.path().dirname(filename)
        ;
        
        var require_ = function (file) {
            return require(file, dirname);
        };
        require_.resolve = function (name) {
            return require.resolve(name, dirname);
        };
        require_.modules = require.modules;
        require_.define = require.define;
        require_.cache = require.cache;
        var module_ = { exports : {} };
        
        require.modules[filename] = function () {
            require.cache[filename] = module_;
            fn.call(
                module_.exports,
                require_,
                module_,
                module_.exports,
                dirname,
                filename,
                process
            );
            return module_.exports;
        };
    };
})();


require.define("path",function(require,module,exports,__dirname,__filename,process){function filter (xs, fn) {
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (fn(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length; i >= 0; i--) {
    var last = parts[i];
    if (last == '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Regex to split a filename into [*, dir, basename, ext]
// posix version
var splitPathRe = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
var resolvedPath = '',
    resolvedAbsolute = false;

for (var i = arguments.length; i >= -1 && !resolvedAbsolute; i--) {
  var path = (i >= 0)
      ? arguments[i]
      : process.cwd();

  // Skip empty and invalid entries
  if (typeof path !== 'string' || !path) {
    continue;
  }

  resolvedPath = path + '/' + resolvedPath;
  resolvedAbsolute = path.charAt(0) === '/';
}

// At this point the path should be resolved to a full absolute path, but
// handle relative paths to be safe (might happen when process.cwd() fails)

// Normalize the path
resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
var isAbsolute = path.charAt(0) === '/',
    trailingSlash = path.slice(-1) === '/';

// Normalize the path
path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }
  
  return (isAbsolute ? '/' : '') + path;
};


// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    return p && typeof p === 'string';
  }).join('/'));
};


exports.dirname = function(path) {
  var dir = splitPathRe.exec(path)[1] || '';
  var isWindows = false;
  if (!dir) {
    // No dirname
    return '.';
  } else if (dir.length === 1 ||
      (isWindows && dir.length <= 3 && dir.charAt(1) === ':')) {
    // It is just a slash or a drive letter with a slash
    return dir;
  } else {
    // It is a full dirname, strip trailing slash
    return dir.substring(0, dir.length - 1);
  }
};


exports.basename = function(path, ext) {
  var f = splitPathRe.exec(path)[2] || '';
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPathRe.exec(path)[3] || '';
};
});

require.define("__browserify_process",function(require,module,exports,__dirname,__filename,process){var process = module.exports = {};

process.nextTick = (function () {
    var queue = [];
    var canPost = typeof window !== 'undefined'
        && window.postMessage && window.addEventListener
    ;
    
    if (canPost) {
        window.addEventListener('message', function (ev) {
            if (ev.source === window && ev.data === 'browserify-tick') {
                ev.stopPropagation();
                if (queue.length > 0) {
                    var fn = queue.shift();
                    fn();
                }
            }
        }, true);
    }
    
    return function (fn) {
        if (canPost) {
            queue.push(fn);
            window.postMessage('browserify-tick', '*');
        }
        else setTimeout(fn, 0);
    };
})();

process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];

process.binding = function (name) {
    if (name === 'evals') return (require)('vm')
    else throw new Error('No such module. (Possibly not yet loaded)')
};

(function () {
    var cwd = '/';
    var path;
    process.cwd = function () { return cwd };
    process.chdir = function (dir) {
        if (!path) path = require('path');
        cwd = path.resolve(dir, cwd);
    };
})();
});

require.define("/package.json",function(require,module,exports,__dirname,__filename,process){module.exports = {}});

require.define("/app.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');
var animate = uijs.animation;
var positioning = uijs.positioning;
var image = require('uijs-controls').image;
var loadimage = uijs.util.loadimage;
var panel = require('./station-panel');

function map(options) {
  var obj = box(defaults(options, {
    markers: [], // a marker contains at least { location: [ lat, long ] }
    region: {
      center: [ 0, 0 ],
      distance: [ 10, 10 ],
    },
    userLocation: {
      visible: false,
      track: true,
      heading: false,
    },
  }));

  var native_map = nativeobj('UIJSMap', obj._id, {});

  // forward all events from `native_map` to `obj` (like!)
  native_map.forward(obj);

  var last_bounds;

  obj.watch = function(attr_or_fn, callback) {
    var self = this;

    if (typeof attr_or_fn !== 'function') {
      var attr = attr_or_fn;
      attr_or_fn = function() {
        return self[attr];
      }
    }

    var last_value = null;
    obj.on('frame', function() {
      var curr_value = JSON.stringify(attr_or_fn()); // serialize
      if (last_value !== curr_value) {
        callback.call(self, curr_value, last_value);
        last_value = curr_value;
      }
    });
  };

  obj.watch(
    function() { return obj.x + ',' + obj.y + '-' + obj.width + 'x' + obj.height; }, 
    function() {
      native_map.call('move', {
        x: obj.x,
        y: obj.y,
        width: obj.width,
        height: obj.height
      });
    });

  obj.watch('markers', function() {
    native_map.call('set_markers', obj.markers);
  });

  obj.watch('region', function() {
    native_map.call('set_region', obj.region);
  });

  obj.watch('userLocation', function() {
    native_map.call('set_user_location', obj.userLocation);
  });

  obj.ondraw = function(ctx) {
    ctx.clearRect(0, 0, this.width, this.height);
  };

  var last_bounds;

  return obj;
}

var app = box();

var TLV = {
  center: [32.0696, 34.7781],
  distance: [1000,1000],
};

var map1 = app.add(map({
  height: positioning.parent.height(),
  width: positioning.parent.width(),
  title: 'Map1',
  region: TLV,
}))


var model = require('./model').createModel();

model.on('update', function() {
  console.log('new markers:', model.stations);
  map1.markers = model.stations;
});

var p = app.add(panel({
  id: '#panel',
  x: positioning.parent.centerx(), 
  y: -167,
  station: function() { return map1.current_marker; },
}));

map1.on('marker-selected', function(m) {
  map1.region = {
    center: m.location,
    distance: [1000, 1000], // 1km
  };

  map1.current_marker = m;
  p.animate({ y: 0 });
});

map1.on('marker-deselected', function() {
  p.animate({ y: -167 }, { ondone: function() {
    map1.current_marker = null;
  }});
});

map1.on('move', function() {
  p.animate({ y: -167 });
});

module.exports = app;});

require.define("/node_modules/uijs/package.json",function(require,module,exports,__dirname,__filename,process){module.exports = {"main":"./lib/index"}});

require.define("/node_modules/uijs/lib/index.js",function(require,module,exports,__dirname,__filename,process){exports.canvasize = require('./canvasize');
exports.box = require('./box');
exports.html = require('./html');
exports.util = require('./util');
exports.positioning = require('./positioning');
exports.interaction = require('./interaction');
exports.animation = require('./animation');
exports.events = require('./events');

exports.kinetics = require('./kinetics');
exports.scroller = require('./scroller');});

require.define("/node_modules/uijs/lib/canvasize.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
var capture = require('./interaction').capture;

module.exports = function(options) {
  options = options || {};

  // we are "DOMfull" if we have a `window` object.
  var domless = (typeof window === 'undefined');

  // by default, start non-paused unless we are domless.
  options.paused = 'paused' in options ? options.paused : domless;

  // by default we do not do auto resize
  options.autoresize = 'autoresize' in options ? options.autoresize : false;

  // shim `window` for DOM-less executions (e.g. node.js)
  if (domless) window = {};

  window.requestAnimationFrame || (
    window.requestAnimationFrame = 
    window.webkitRequestAnimationFrame || 
    window.mozRequestAnimationFrame    || 
    window.oRequestAnimationFrame      || 
    window.msRequestAnimationFrame     || 
    function(cb) { setTimeout(cb, 1000/60); }
  );

  window.devicePixelRatio || (window.devicePixelRatio = 1);

  var canvas = null;

  if (options.element) {
    canvas = options.element;
    canvas.width = canvas.width || parseInt(canvas.style.width) * window.devicePixelRatio;
    canvas.height = canvas.height || parseInt(canvas.style.height) * window.devicePixelRatio;
  }
  else {
    if (typeof document === 'undefined') {
      throw new Error('No DOM. Please pass a Canvas object (e.g. node-canvas) explicitly');
    }

    if (document.body.hasChildNodes()) {
      while (document.body.childNodes.length) {
        document.body.removeChild(document.body.firstChild);
      }
    }

    document.body.style.background = 'rgba(0,0,100,0.0)';
    document.body.style.padding = '0px';
    document.body.style.margin = '0px';

    canvas = document.createElement('canvas');
    canvas.style.background = 'rgba(0,0,0,0.0)';
    document.body.appendChild(canvas);

    function adjust_size() {
      // http://joubert.posterous.com/crisp-html-5-canvas-text-on-mobile-phones-and
      canvas.width = window.innerWidth * window.devicePixelRatio;
      canvas.height = window.innerHeight * window.devicePixelRatio;
      canvas.style.width = window.innerWidth;
      canvas.style.height = window.innerHeight;

      var c = canvas.getContext('2d');
      c.scale(window.devicePixelRatio, window.devicePixelRatio);
    }

    window.onresize = function() {
      if (main && main.autoresize) {
        adjust_size();
      }
    };

    document.body.onorientationchange = function() {
      adjust_size();
    };

    setTimeout(function() { 
      window.scrollTo(0, 0);
      adjust_size();
      window.onresize();
    }, 0);

    adjust_size();
  }

  var ctx = canvas.getContext('2d');

  options = options || {};
  options.id = options.id || 'canvas';
  options.x = options.x || 0;
  options.y = options.y || 0;
  options.width = options.width || function() { return canvas.width / window.devicePixelRatio; };
  options.height = options.height || function() { return canvas.height / window.devicePixelRatio; };

  var main = box(options);

  main.domless = domless;
  main.canvas = canvas;

  // hook canvas events to `main.interact()`.
  capture(canvas, function(event, coords, e) {
    return main.interact(event, coords, e);
  });

  main.paused = options.paused;

  function redraw(force) {
    if (!force && main.paused) return; // stop redraw loop if we are paused.

    //TODO: since the canvas fills the screen we don't really need this?
    if (main.alpha && main.alpha() < 1.0) {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
    }

    main.draw(ctx);

    if (!main.paused) window.requestAnimationFrame(redraw);
  }
  
  if (!main.paused) {
    redraw();
  }

  main.redraw = function() {
    redraw(true);
  };

  main.pause = function() {
    this.paused = true;
  };

  main.resume = function() {
    this.paused = false;
    redraw(); // kick start redraw
  };

  return main;
};});

require.define("/node_modules/uijs/lib/box.js",function(require,module,exports,__dirname,__filename,process){var defaults = require('./util').defaults;
var valueof = require('./util').valueof;
var propertize = require('./util').propertize;
var animate = require('./animation');

var EventEmitter = require('./events').EventEmitter;

var idgenerator = 0;


var box = module.exports = function(options) {

  var attributes = defaults(options, {
    x: 0,
    y: 0,
    width: 100,
    height: 100,
    children: [],
    rotation: 0.0,
    visible: true,
    clip: false,
    alpha: null,
    debug: false,
    interaction: true, // send interaction events on this box. must be set to true for events to be emitted
    autopropagate: true, // propagate interaction events to child boxes. if false, the parent needs to call `e.propagate()` on the event
    id: function() { return this._id; },
  });

  // TODO: extend()
  var obj = new EventEmitter();

  for (var k in attributes) {
    obj[k] = attributes[k];
  }

  // turn all attributes except `onxxx` and anything that begins with a '_' to properties.
  propertize(obj, function(attr) {
    return !(attr.indexOf('on') === 0 || attr.indexOf('_') === 0);
  });

  var prev_children = obj.children;

  obj.properties.onchange('children', function(c) {
    var _push = c.push;

    c.forEach(function(i) {
      i.parent = obj;
    });

    c.push = function(child) {
      child.parent = obj;
      return _push.apply(c, arguments);
    };
  });

  obj.children = prev_children;

  obj._id = 'BOX.' + idgenerator++;
  obj._is_box  = true;

  /// ## Box Hierarchy
  /// Boxes have children and parents.

  // returns the root of the box hierarchy
  obj.root = function() {
    var self = this;
    if (!self.parent) return self;
    return self.parent.root();
  };

  // adds a child to the end of the children's stack.
  obj.add = obj.push = function(child) {
    var self = this;
    if (Array.isArray(child)) {
      return child.forEach(function(c) {
        self.add(c);
      });
    }

    if (!box.isbox(child)) {
      throw new Error('can only add boxes as children to a box');
    }

    child.parent = self;
    self.children.push(child);

    return child;
  };

  obj.tofront = function() {
    var self = this;
    if (!self.parent) throw new Error('`tofront` requires that the box will have a parent');
    var parent = self.parent;
    parent.remove(self);
    parent.push(self);
    return self;
  };

  obj.siblings = function() {
    var self = this;
    if (!self.parent) return [ self ]; // detached, no siblings but self
    return self.parent.all();
  };

  obj.prev = function() {
    var self = this;
    if (!self.parent) throw new Error('box must be associated with a parent')
    var children = self.parent.children;
    var my_index = children.indexOf(self);
    if (my_index === 0) return null;
    else return children[my_index - 1];
  };

  // removes a child (or self from parent)
  obj.remove = function(child) {
    var self = this;

    if (!child) {
      if (!self.parent) throw new Error('`remove()` will only work if you have a parent');
      self.parent.remove(self);
      return child;
    }

    var children = self.children;

    var child_index = children.indexOf(child);
    if (child_index === -1) return;
    children.splice(child_index, 1);
    child.parent = null;
    return child;
  };

  // removes all children
  obj.empty = function() {
    var self = this;
    self.children = [];
    return self;
  };

  // retrieve a child by it's `id()` property (or _id). children without
  // this property cannot be retrieved using this function.
  obj.get = function(id) {
    var self = this;
    var result = self.children.filter(function(child) {
      return child.id === id;
    });

    return result.length === 0 ? null : result[0];
  };

  // ### box.query(id)
  // Retrieves a child from the entire box tree by id.
  obj.query = function(id) {
    var self = this;
    var child = self.get(id);
    if (child) return child;

    var children = self.children;
    for (var i = 0; i < children.length; ++i) {
      var child = children[i];
      var result = child.query(id);
      if (result) {
        return result;
      }
    }
  };

  /// ### box.all()
  /// Returns all the children of this box.
  obj.all = function() {
    var self = this;
    return self.children;
  };

  /// ### box.rest([child])
  /// Returns all the children that are not `child` (or do the same on the parent if `child` is null)
  obj.rest = function(child) {
    var self = this;
    if (!child) {
      if (!obj.parent) throw new Error('cannot call `rest()` without a parent');
      return obj.parent.rest(self);
    }

    return self.children.filter(function(c) {
      return c.id !== child.id;
    });
  };

  // returns the first child
  obj.first = function() {
    var self = this;
    return self.children[0];
  };

  // returns a tree representation this box and all it's children
  obj.tree = function(indent) {
    var box = this;
    indent = indent || 0;

    var s = '';
    for (var i = 0; i < indent; ++i) {
      s += ' ';
    }

    s += box.id + '\n';
    
    box.children.forEach(function(child) {
      s += child.tree(indent + 2);
    });

    return s;
  }

  /// ## Drawing

  /// ### box.ondraw(ctx)
  /// `ondraw` is called __every frame__ with a `CanvasRenderingContext2D` as a single
  /// parameter. The box should draw itself as efficiently as possible.
  obj.ondraw = null;

  /// ### box.draw(ctx)
  /// This function is called every frame. It draws the current box (by means of calling `ondraw`)
  /// and then draws the box's children iteratively. This function also implements a few of the basic
  /// drawing capabilities and optimizations: buffering, clipping, scaling, rotation.
  obj.draw = function(ctx) {
    var self = this;

    var children = self.children;

    if (!self.visible || self.alpha === 0.0) return;

    ctx.save();

    if (self.rotation) {
      var centerX = self.x + self.width / 2;
      var centerY = self.y + self.height / 2;
      ctx.translate(centerX, centerY);
      ctx.rotate(self.rotation);
      ctx.translate(-centerX, -centerY);
    }

    // stuff that applies to all children
    ctx.translate(self.x, self.y);
    if (self.alpha) ctx.globalAlpha = self.alpha;

    if (self.clip) {
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(self.width, 0);
      ctx.lineTo(self.width, self.height);
      ctx.lineTo(0, self.height);
      ctx.closePath();
      ctx.clip();
    }

    ctx.save();

    // stuff that applies only to this child

    // emit a `frame` event
    self.emit('frame');

    // call `ondraw` for rendering.
    if (self.ondraw) {
      if (self.width > 0 && self.height > 0) {
        self.ondraw(ctx);
      }
    }

    ctx.restore();

    children.forEach(function(child) {
      //TODO: do not draw child if out of viewport
      child.draw.call(child, ctx);
    });

    ctx.restore();
  };

  // -- interactivity

  // given a `pt` in box coordinates, returns a child
  // that resides in those coordinates. returns { child, child_pt }
  // `filter` is a function that, if returns `false` will ignore a child.
  obj.hittest = function(pt, filter) {
    var self = this;

    if (!pt || !('x' in pt) || !('y' in pt)) return;

    // we go in reverse order because the box stack is based on this.
    var children = self.children.reverse();

    for (var i = 0; i < children.length; ++i) {
      var child = children[i];

      // ignore child if filter is activated
      if (filter && !filter(child)) continue;

      if (pt.x >= child.x &&
          pt.y >= child.y &&
          pt.x <= child.x + child.width &&
          pt.y <= child.y + child.height) {
        
        // convert to child coords
        var child_x = pt.x - child.x;
        var child_y = pt.y - child.y;

        return {
          child: child,
          child_pt: { x: child_x, y: child_y }
        };
      }
    }

    return null;
  };
  
  obj.interact = function(event, pt) {
    var self = this;

    // emit events for all children that required to capture them.
    self._emit_captures(event, pt);

    // if this box does not interaction events, ignore.
    if (!self.interaction) return;

    // queue the event locally to this box (if not capturing)
    if (self.debug) console.log('[' + self.id + ']', event, pt);
    if (!self.capturing()) {
      self.emit(event, pt);
    }

    // nothing to do if `propagate` is false.
    if (self.autopropagate) {
      self.propagate(event, pt);
    }

    // delete all captures that were stopped during this cycle.
    // if we delete them immediately, we get duplicate events if `stopCapture`
    // is called by the event handler (and then self.capturing() is true).
    self._delete_captures();

    return true;
  };

  // propagates an event to any child box that is hit by `pt`.
  // `pt` is in box coordinates and the event is propagated in child coordinates.
  obj.propagate = function(event, pt) {
    var self = this;

    // check if the event should be propagated to one of the children
    var hit = self.hittest(pt, function(child) { return child.interaction; });
    if (hit) {
      return hit.child.interact(event, hit.child_pt);
    }

    return false;
  };

  // returns the screen coordinates of this obj
  obj.screen = function() {
    var self = this;

    if (self.canvas) {
      return {
        x: self.canvas.offsetParent.offsetLeft + self.canvas.offsetLeft,
        y: self.canvas.offsetParent.offsetTop + self.canvas.offsetTop,
      };
    }

    var pscreen = self.parent ? self.parent.screen() : { x: 0, y: 0 };
    return {
      x: pscreen.x + self.x,
      y: pscreen.y + self.y,
    };
  };

  // translates `pt` in the current box's coordinates to `box` coordinates.
  obj.translate = function(pt, box) {
    var boxscreen = box.screen();
    var myscreen = this.screen();
    return {
      x: pt.x + myscreen.x - boxscreen.x,
      y: pt.y + myscreen.y - boxscreen.y,
    };
  };

  // -- capture events

  // emits events to all boxes that called `startCapture`.
  obj._emit_captures = function(event, pt) {
    var self = this;
    if (!self._captures) return; // no captures on this level (only on root)
    for (var id in self._captures) {
      var child = self._captures[id];
      var child_pt = self.translate(pt, child);
      child.emit(event, child_pt);
    }
  };

  // delete all captures that were stopped during this event cycle
  obj._delete_captures = function() {
    var self = this;
    if (!self._captures_to_delete) return;
    if (self._captures) {
      self._captures_to_delete.forEach(function(id) {
        delete self._captures[id];
      });
    }

    self._captures_to_delete = [];
  };

  // registers this box to receive all interaction events until `stopCapture` is called.
  obj.startCapture = function() {
    var root = this.root();
    var captures = root._captures;
    if (!captures) captures = root._captures = {};
    captures[this._id] = this;
  };

  // stops sending all events to this box.
  obj.stopCapture = function() {
    var root = this.root();
    var captures = root._captures;
    if (!captures) return;
    if (!root._captures_to_delete) {
      root._captures_to_delete = [];
    }
    root._captures_to_delete.push(this._id);
  };

  // returns true if events are currently captured by this box.
  obj.capturing = function() {
    var root = this.root();
    var captures = root._captures;
    if (!captures) return false;
    return this._id in captures;
  };

  // -- animation

  obj.animate = function(properties, options) {
    var self = this;
    Object.keys(properties).forEach(function(k) {
      var curr = self[k];
      var target = properties[k];
      if (self.debug) console.log('[' + self.id + ']', 'animating', k, 'from', curr, 'to', target);
      self[k] = animate(curr, target, options);
    });
  };  

  return obj;
};

box.isbox = function(obj) {
  return obj._is_box || obj._is_view;
};});

require.define("/node_modules/uijs/lib/util.js",function(require,module,exports,__dirname,__filename,process){var EventEmitter = require('./events').EventEmitter;

exports.min = function(a, b) { return a < b ? a : b; };
exports.max = function(a, b) { return a > b ? a : b; };

// returns a function that creates a new object linked to `this` (`Object.create(this)`).
// any property specified in `options` (if specified) is assigned to the child object.
exports.derive = function(options) {
  return function() {
    var obj = Object.create(this);
    obj.base = this;
    if (options) {
      for (var k in options) {
        obj[k] = options[k];
      }
    }
    return obj;
  };  
};

// returns the value of `obj.property` if it is defined (could be `null` too)
// if not, returns `def` (or false). useful for example in tri-state attributes where `null` 
// is used to disregard it in the drawing process (e.g. `fillStyle`).
exports.valueof = function(obj, property, def) {
  if (!obj) throw new Error('`obj` is required');
  if (!def) def = false;
  if (!(property in obj)) return def;
  else return obj[property];
};

exports.defaults = function(target, source) {
  var valueof = exports.valueof;

  target = target || {};

  for (var k in source) {
    target[k] = valueof(target, k, source[k]);
  }

  return target;
};

exports.loadimage = function(src) {
  if (typeof src === 'function') src = src();
  
  var img = new Image();
  img.src = src;
  img.onload = function() { };

  return function() {
    return img;
  }
};

// turns all attributes of `obj` into functional properties.
// `filter` (`function(attr)`) can be used to filter out any attributes.
exports.propertize = function(obj, filter) {
  filter = filter || function(attr) { return true; }; 

  if (!obj.properties) {
    obj.properties = [];
    obj.properties._ee = new EventEmitter();
    obj.properties.onchange = function(prop, callback) {
      return obj.properties._ee.on(prop, callback);
    };
  }

  function prop(obj, name) {
    var prev = obj[name];

    var curr = null;
    var prev_value = null;

    Object.defineProperty(obj, name, {
      get: function() {
        if (typeof curr === 'function') {
          var new_value = curr.call(this);
          if (new_value !== prev_value){
            obj.properties._ee.emit(name, new_value, prev_value);
          }
          prev_value = new_value;
          return new_value;
        }

        else return curr;
      },
      set: function(value) {
        if (typeof value !== 'function') {
          obj.properties._ee.emit(name, value, curr);
          prev_value = null;
        }

        curr = value;
      }
    });

    obj[name] = prev;
    obj.properties.push(name); // manage a list of property names
  }

  for (var attr in obj) {
    if (!obj.hasOwnProperty(attr)) continue; // skip properties from linked objects
    if (!filter(attr)) continue;
    if (attr === 'properties') continue;
    prop(obj, attr);
  }

  return obj;
};
});

require.define("/node_modules/uijs/lib/events.js",function(require,module,exports,__dirname,__filename,process){function EventEmitter() {
  var self = this;
  
  self._subscriptions = {};
  self._pipes = [];

  return self;
}

EventEmitter.prototype.emit = function(event) {
  var self = this;

  var handlers = self._subscriptions[event];
  var original_arguments = arguments;

  var handled;

  if (handlers) {
    var args = [];
    for (var i = 1; i < arguments.length; ++i) {
      args.push(arguments[i]);
    }

    handlers.forEach(function(fn) {
      var ret = fn.apply(self, args);
      if (typeof ret === 'undefined' || ret === true) handled = true;
      if (ret === false) handled = false;
    });
  }


  // emit events on all pipes
  self._pipes.forEach(function(target) {
    var ret = target.emit.apply(target, original_arguments);
    if (typeof ret === 'undefined' || ret === true) handled = true;
    if (ret === false) handled = false;
  });

  return handled;
};

// emits the event (with arguments) after 100ms
// should be used to allow ui to update when emitting
// events from event handlers.
EventEmitter.prototype.queue = function(event) {
  var self = this;
  var args = arguments;
  setTimeout(function() {
    self.emit.apply(self, args);
  }, 5);
};

EventEmitter.prototype.on = function(event, handler) {
  var self = this;
  if (!self._subscriptions) return;
  var handlers = self._subscriptions[event];
  if (!handlers) handlers = self._subscriptions[event] = [];
  handlers.push(handler);

  return self;
};

EventEmitter.prototype.removeAllListeners = function(event) {
  var self = this;
  if (!self._subscriptions) return;
  delete self._subscriptions[event];
  return self;
};

EventEmitter.prototype.removeListener = 
EventEmitter.prototype.off = function(event, handler) {
  var self = this;
  if (!self._subscriptions) return;
  var handlers = self._subscriptions[event];

  var found = -1;
  for (var i = 0; i < handlers.length; ++i) {
    if (handlers[i] === handler) {
      found = i;
    }
  }

  if (found !== -1) {
    handlers.splice(found, 1);
  }

  return self;
};

// forward all events from this EventEmitter to `target`.
EventEmitter.prototype.forward = function(target) {
  var self = this;
  self._pipes.push(target);
  return self;
};

// remove a forward
EventEmitter.prototype.unforward = function(target) {
  var self = this;
  var i = self._pipes.indexOf(target);
  if (i === -1) return false;
  self._pipes.splice(i, 1);
  return true;
};

exports.EventEmitter = EventEmitter;});

require.define("/node_modules/uijs/lib/animation.js",function(require,module,exports,__dirname,__filename,process){// -- animation
var curves = exports.curves = {};

curves.linear = function() {
  return function(x) {
    return x;
  };
};

curves.easeInEaseOut = function() {
  return function(x) {
    return (1 - Math.sin(Math.PI / 2 + x * Math.PI)) / 2;
  };
};

module.exports = function(from, to, options) {
  options = options || {};
  options.duration = options.duration || 250;
  options.ondone = options.ondone || function() { };
  options.curve = options.curve || curves.easeInEaseOut();
  options.name = options.name || from.toString() + '_to_' + to.toString();

  var startTime = Date.now();
  var endTime = Date.now() + options.duration;
  var callbackCalled = false;

  return function () {
    var elapsedTime = Date.now() - startTime;
    var ratio = elapsedTime / options.duration;
    if (ratio < 1.0) {
      curr = from + (to - from) * options.curve(ratio);
    }
    else {
      // console.timeEnd(options.name);
      curr = to;
      if (options.ondone && !callbackCalled) {
        options.ondone.call(this);
        callbackCalled = true;
      }
    }
    return curr;
  };
};});

require.define("/node_modules/uijs/lib/interaction.js",function(require,module,exports,__dirname,__filename,process){// maps DOM events to uijs event names
var EVENTS = {
  ontouchstart: 'touchstart',
  ontouchmove : 'touchmove',
  ontouchend  : 'touchend',
  onmousedown : 'touchstart',
  onmousemove : 'touchmove',
  onmouseup   : 'touchend',
};

function capture(el, fn) {

  // bind to all mouse/touch interaction events
  Object.keys(EVENTS).forEach(function(k) {
    el[k] = function(e) {
      var name = EVENTS[k];
      e.preventDefault();
      var coords = (name !== 'touchend' || !e.changedTouches) ? relative(e) : relative(e.changedTouches[0]);
      return fn(name, coords, e);
    };
  });

  // get the coordinates for a mouse or touch event
  // http://www.nogginbox.co.uk/blog/canvas-and-multi-touch
  function relative(e) {
    if (e.touches && e.touches.length > 0) {
      e = e.touches[0];
      return { x: e.pageX - el.offsetLeft, y: e.pageY - el.offsetTop };
    }
    else if (e.offsetX) {
      // works in chrome / safari (except on ipad/iphone)
      return { x: e.offsetX, y: e.offsetY };
    }
    else if (e.layerX) {
      // works in Firefox
      return { x: e.layerX, y: e.layerY };
    }
    else if (e.pageX) {
      // works in safari on ipad/iphone
      return { x: e.pageX - el.offsetLeft, y: e.pageY - el.offsetTop };
    }
  }

}

exports.capture = capture;});

require.define("/node_modules/uijs/lib/html.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
var util = require('./util');
var capture = require('./interaction').capture;
var defaults = util.defaults;

module.exports = function(options) {
  options = defaults(options, {
    html: '<div>',
    interaction: false, // by default we let HTML capture events
  });

  var obj = box(options);

  var last_bounds = null;

  obj.on('frame', function() {
    var self = this;

    var pt = this.screen();
    var bounds = pt.x + ',' + pt.y + ' ' + this.width + 'x' + this.height;

    if (bounds !== last_bounds) {
      var div = self._container(); // ensure that the element exists.

      // update bounds
      div.style.left = pt.x;
      div.style.top = pt.y;
      div.style.width = this.width;

      // clip to parent bounds or nasty things will happen.
      div.style.height = util.min(this.height, this.parent.height - this.y);

      last_bounds = bounds;
    }
  });

  Object.defineProperty(obj, 'container', {
    get: function() {
      var self = this;
      if (!self._div) return null;
      return self._container();
    },
  })

  // returns the `div` container that hosts this tag.
  // the div will be created and appended to the document body
  // if it ain't.
  obj._container = function() {
    var self = this;
    var div = self._div;
    if (!div) {
      div = self._div = document.createElement('div');
      div.style.overflow = 'auto';
      div.style.position = 'absolute';
      document.body.appendChild(self._div);

      div.innerHTML = self.html;

      if (self.interaction) {
        capture(div, function(event, pt, e) {
          // we need to pass the interaction data to the canvas
          var root = self.root();
          var spt = self.screen();
          root.interact(event, {
            x: pt.x + spt.x,
            y: pt.y + spt.y,
          }, e);
        });
      }

      if (self.onload) {
        self.onload(div);
      }
    }

    return div;
  };

  return obj;
};});

require.define("/node_modules/uijs/lib/positioning.js",function(require,module,exports,__dirname,__filename,process){//
// attributes

var attributes = {};

attributes.top = attributes.y = function(box, delta) {
  return function() {
    return box.y + (delta || 0);
  }
};

attributes.left = attributes.x = function(box, delta) { 
  return function() {
    return box.x + (delta || 0);
  }
};

attributes.right = function(box, delta) {
  return function() {
    return box.x + box.width + (delta || 0);
  }
};

attributes.bottom = function(box, delta) {
  return function() {
    return box.y + box.height + (delta || 0);
  };
};

attributes.width = function(box, delta) {
  return function() {
    return box.width + (delta || 0);
  }
};

attributes.height = function(box, delta) {
  return function() {
    return box.height + (delta || 0);
  }
};

attributes.centerx = function(box, delta) {
  return function() {
    return box.width / 2 - this.width / 2 + (delta || 0);
  }
};

attributes.centery = function(box, delta) {
  return function() {
    return box.height / 2 - this.height / 2 + (delta || 0);
  }
};

// export all attributed positional functions
for (var k in attributes) {
  exports[k] = attributes[k];
}

//
// relations

var zero = {
  x: 0,
  y: 0,
  width: 0,
  height: 0,
};

exports.parent = mkrelational(function() {
  if (!this.parent) throw new Error('no parent');
  return this.parent;
});

exports.prev = mkrelational(function() {
  if (!this.parent) throw new Error('no parent no prev()');
  var prev = this.prev();

  // if no prev, it means we are the first, so just assume all 0
  if (!prev) return zero;

  return prev;
});

exports.relative = function(query) {
  return mkrelational(function() {
    var box = this.root().query(query);
    if (!box) return zero;
    return box;
  });
};

// --- private

// returns a hash of positional attributed functions bound to the
// box returned by the `related` function.
function mkrelational(related) {
  if (!related || typeof related !== 'function') throw new Error('`related` must be a function');
  var functions = {};
  Object.keys(attributes).forEach(function(attr) {
    var attrfn = attributes[attr];
    functions[attr] = function(delta) {
      return function() {
        var self = this;
        delta = delta || 0;
        return attrfn(related.call(self), delta).call(self);
      };
    };
  });

  return functions;
}});

require.define("/node_modules/uijs/lib/kinetics.js",function(require,module,exports,__dirname,__filename,process){function c(x) { return function() { return x; }; }

function calculateDirection(velocity){
  return Math.abs(velocity) / velocity;
}

function calculateSpeed(v0, acceleration, friction, delta_ts){
  var delta_speed = acceleration * delta_ts;
  return v0 * friction + delta_speed;
}

function calculatePosition(x0, velocity, delta_ts){
  var delta_x = velocity * delta_ts;
  return x0 += delta_x;    
}

function surfaceWithForces(options){
  options = options || {};
  var friction = options.friction || c(0.993);
  var last_ts = Date.now();
  // The time delta for which to calculate the spring action (in seconds). If not set then will take from intervals between calls to the returned function, starting from now
  var delta_ts = options.delta_ts || function(){
    var now = Date.now();
    var calculatedDelta = (now - last_ts) / 1000;
    last_ts = now;
    return calculatedDelta;
  };
  var time_unit = options.time_unit ? options.time_unit() : 0.001; //(In seconds) The calculation will be done for each time unit 
  var acceleration = options.acceleration || c(0);

  var returnValue = {
    position: options.initialPosition ? options.initialPosition() : 0,      
    velocity: options.initialVelocity ? options.initialVelocity() : 0.0, // In pixels per second
    
    animate: function(){
      var self = this;
      var timespan = delta_ts();
      for (var i = 0; i < timespan; i += time_unit) {
        self.velocity = calculateSpeed(self.velocity, acceleration(), friction(), time_unit);
        self.position = calculatePosition(self.position, self.velocity, time_unit);
      }
      return self.position;
    },
  }

  return returnValue;
}

function springAnimation(base, elasticity, options){
  options = options || {};
  var elasticity = options.elasticity || c(65);
  var swf;
  var calculateAcceleration = function(){
    return -((swf.position - base) * elasticity);
  };

  options.friction = options.friction || c(0.995);
  if (options.acceleration) {alert("Cannot define acceleration for a spring, just elasticity and base");};
  options.acceleration = calculateAcceleration;
  var swf = surfaceWithForces(options);

  return swf;    
}

function basicSliderAnimation(options){
  options = options || {};
  options.friction = options.friction || c(0.995);
  return surfaceWithForces(options);
}

function carouselAnimation(carouselleftBase, carouselRightBase, initialPosition, initialVelocity, inSpringMode, initialSpringBase, options){

  options = options || {};
  var elasticity = options.elasticity || c(65);
  var springFriction = options.springFriction || c(0.993);
  var regularFriction = options.regularFriction || c(0.995);
  var springVelocityThreshold = options.springVelocityThreshold || c(300); //Under this velocity (in pixels per sec) the surface will become a spring whose base is the current position
  var time_unit = options.time_unit = options.time_unit || c(0.001); //(In seconds) The calculation will be done for each time unit 
  var last_ts = Date.now();
  // The time delta for which to calculate the spring action (in seconds). If not set then will take from intervals between calls to the returned function, starting from now
  var delta_ts = options.delta_ts || function(){
    var now = Date.now();
    var calculatedDelta = (now - last_ts) / 1000;
    last_ts = now;
    return calculatedDelta;
  };

  var swf;
  var direction = calculateDirection(initialVelocity());
  var nonSpringAcceleration = options.nonSpringAcceleration || function() {return -((swf.velocity / 0.5) + (100 * direction));};

  var determineSpring = function(){
    var leftBase = carouselleftBase();
    var rightBase = carouselRightBase();

    if (swf.position > leftBase) {
      swf.spring = true;
      swf.spring_base = leftBase;
    }
    else if (swf.position < rightBase) {
      swf.spring = true;
      swf.spring_base = rightBase;
    }
    else if (!swf.spring && Math.abs(swf.velocity) < springVelocityThreshold()) {
      swf.spring = true;
      swf.spring_base = swf.position;
    }
  };

  var now = Date.now();
  var options = {
    initialPosition: initialPosition,
    initialVelocity: initialVelocity,
    delta_ts: delta_ts,
    time_unit: time_unit,
    acceleration: function(){
      determineSpring();
      if (swf.spring) {
        return -((swf.position - swf.spring_base) * elasticity());
      }
      else{
        return nonSpringAcceleration();
      }
    },
    friction: function(){  
      determineSpring();
      if (swf.spring) {
        return springFriction();
      }
      else{
        return regularFriction();
      }
    },
  };
  swf = surfaceWithForces(options);
  swf.spring_base = initialSpringBase();
  swf.spring = inSpringMode();
  return swf;
}

function carouselBehavior(spring_left_base, spring_right_base, spring_max_stretch, eventHistory, onClick, options){
  options = options || {};

  var last_touch_position = 0;
  var last_position = 0;
  var last_timestamp;
  var last_speed; // In pixels per second
  var touching = false;
  var moving = false;
  var spring = false;
  var spring_base = 0;

  return function(){
    while (eventHistory.length > 0){
      var oldestEvent = eventHistory.shift();
      var previous_touch_position = last_touch_position;
      last_touch_position = oldestEvent.position;
      var previous_touch_timestamp = last_timestamp;
      last_timestamp = oldestEvent.timestamp;
        
      if (oldestEvent.name === "touchstart") {
        touching = true;
        moving = false;
        spring = false;
      }

      if (oldestEvent.name === "touchmove") {
        touching = true;
        moving = true;
        var delta_position = last_touch_position - previous_touch_position;
        var delta_ts = (last_timestamp - previous_touch_timestamp) / 1000; //In seconds
        if ((last_position > spring_left_base() && delta_position > 0) || (last_position < spring_right_base() && delta_position < 0)) {
          spring = true;
          if (last_position > spring_left_base()) {
            spring_base = spring_left_base();  
          }
          else{
            spring_base = spring_right_base();
          }
          delta_position = (spring_max_stretch() - ((last_position - spring_base) * calculateDirection(delta_position)) ) / spring_max_stretch() * delta_position; 
        }
        else{
          spring = false;
        }
        last_speed = delta_position / delta_ts;
        if(last_speed > 3500){
          last_speed = 3500;
        }

        last_position += delta_position;
      }

      if (oldestEvent.name === "touchend") {
        touching = false;
        if (!moving) { //We've detected a click without a move!!
          console.log('click', previous_touch_position);
          onClick(previous_touch_position, this);
        }
      }
    }
      
    var swf;
    if ((!isNaN(last_speed) && !touching) && moving){
      var now = Date.now();
      options.delta_ts = c((now - last_timestamp) / 1000);
      swf = carouselAnimation(spring_left_base, spring_right_base, c(last_position), c(last_speed), c(spring), c(spring_base), options);
      last_position = swf.animate();
      spring = swf.spring;
      spring_base = swf.spring_base;
      last_timestamp = now;
      last_speed = swf.velocity;
    }

    return last_position;
  }
}

exports.carouselBehavior = carouselBehavior;});

require.define("/node_modules/uijs/lib/scroller.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
var kinetics = require('./kinetics');
var defaults = require('./util').defaults;
var min = require('./util').min;
var max = require('./util').max;
var scrollbar = require('./scrollbar');

module.exports = function(options) {
  var obj = box(defaults(options, {
    content: box(),
    clip: true,
  }));

  var bar = scrollbar({ 
    width: function() { return obj.width; },
    height: function() { return obj.height; },
    size: function() {
      return obj.height / obj.content.height;
    },
    position: function() {
      return -obj.content.y / obj.content.height;
    },
  });

  obj.children = function() { 
    return [ obj.content, bar ]; 
  };

  var events = [];

  obj.properties.onchange('content', function(value) {
    value.y = kinetics.carouselBehavior(
      function() { return 0; },
      function() { return obj.height - obj.content.height; },
      function() { return 300; },
      events,
      function() { },
      { regularFriction: function() { return 0.997; } });
  });

  var ts = Date.now();
  var frames = 0;
  
  obj.ondraw = function(ctx) {
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, this.width, this.height);

    var newTime = Date.now();
    frames++;
    if ((newTime - ts) > 1000) {
      console.log("fps: " + frames);
      frames = 0;
      ts = newTime;
    };
  };

  obj.on('touchstart', function(coords) {
    this.startCapture();
    events.push({name: 'touchstart', position: coords.y, timestamp: Date.now()});
  });

  obj.on('touchmove', function(coords) {
    if (!this.capturing()) return;
    events.push({name: 'touchmove', position: coords.y, timestamp: Date.now()});
  });

  obj.on('touchend', function(coords) {
    this.stopCapture();
    events.push({name: 'touchend', position: coords.y, timestamp: Date.now()});
  });

  return obj;
};});

require.define("/node_modules/uijs/lib/scrollbar.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
var defaults = require('./util').defaults;
var min = require('./util').min;
var max = require('./util').max;

module.exports = function(options) {
  var obj = box(defaults(options, {
    position: 0.3,
    size: 0.5,
    interaction: false,
  }));

  obj.ondraw = function(ctx) {
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.5)';
    ctx.lineCap = 'round';
    ctx.lineWidth = 10;
    ctx.beginPath();

    var barstart = 8;
    var barheight = this.height - 16;

    var barposition = this.position * barheight;
    var barsize = this.size * barheight;

    ctx.moveTo(this.width - 10, max(barstart + barposition, barstart));
    ctx.lineTo(this.width - 10, min(barstart + barposition + barsize, barstart + barheight));
    ctx.stroke();
  }; 

  return obj;
};});

require.define("/nativeobj.js",function(require,module,exports,__dirname,__filename,process){var EventEmitter = require('uijs').events.EventEmitter;

window.uijs_native_objects = {}; // used to emit events from native code
window.uijs_emit_event = function(objid, event, args) {
  var obj = window.uijs_native_objects[objid];
  if (!obj) {
    console.warn('unable to emit event ' + event + ' from native object with id ' + objid + ' because object not found');
    return; // object not found
  }

  return obj.emit(event, args);
};

module.exports = function(type, id, options) {
  var obj = new EventEmitter();

  var cordova = window.cordova || window.Cordova;
  if (!cordova) {
    console.warn('No phonegap environment. Unable to create native object of type ' + type);
    obj.call = function(method, args, callback) {
      callback = callback || function() {};
      return callback();
    };
    
    return obj;
  }

  // add object to global hash
  window.uijs_native_objects[id] = obj;

  // native.call(method, args, callback)
  // call `method` with `args` on the native object.
  // `args` can be any type of JSONable object
  obj.call = function(method, args, callback) {
    callback = callback || function() {};

    function success() {
      var args = [];

      args.push(null); // err
      
      for (var i = 0; i < arguments.length; ++i) {
        args[i] = arguments[i];
      }

      return callback.apply(obj, args);
    }

    function failure(err) {
      return callback.call(obj, err);
    }

    return cordova.exec(success, failure, 'org.uijs.native', 'invoke', [ method, type, id, JSON.stringify(args) ]);
  };

  obj.call('init', options, function(err) {
    if (!err) {
      alert('init error: ' + err.toString());
    }
  });

  return obj;
};});

require.define("/node_modules/uijs-controls/package.json",function(require,module,exports,__dirname,__filename,process){module.exports = {"main":"lib/index"}});

require.define("/node_modules/uijs-controls/lib/index.js",function(require,module,exports,__dirname,__filename,process){exports.image = require('./image');
exports.listView = require('./listView');
exports.button = require('./button');
exports.label = require('./label');});

require.define("/node_modules/uijs-controls/lib/image.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
var box = uijs.box;
var util = uijs.util;
var defaults = util.defaults;

module.exports = function(options) {
  var obj = box(defaults(options, {
    image: null,
    stretchWidth: false,
    stretchHeight: false,
    fit: false,
    horizontalAlign: 'center',
    verticalAlign: 'middle',
  }));

  obj.ondraw = function(ctx) {
    var self = this;

    if (!self.image) return;

    var img = self.image;
    if (!img) return;
    if (img.width === 0 || img.height === 0) return;

    var strw = self.stretchWidth;
    var strh = self.stretchHeight;
    var boxw = self.width;
    var boxh = self.height;
    var x, y, w, h;

    w = img.width;
    h = img.height;

    if(w > boxw || h > boxh)
    {
      //resize width
      h = h * boxw/w;
      w = boxw;
      //resize height if needed 
      if(h > boxh)
      {
        w = w * boxh/h;
        h = boxh;
      } 
    }

    if(self.fit) {
      if(boxw/w <= boxh/h) {
        h = h * boxw/w;
        w = boxw;
      }
      else {
        w = w * boxh/h;
        h = boxh;
      }
    }
    else {
      if (strw) {
        h = Math.min(h * boxw/w,boxh);
        w = boxw;  
      }
      if (strh) {
        w = Math.min(w * boxh/h,boxw);
        h = boxh;
      }
    }
    
    switch (self.horizontalAlign) {
      case 'left':
        x = 0;
        break;

      case 'right':
        x = boxw - w;
        break;

      case 'center':
      default:
        x = boxw / 2 - w / 2;
        break;
    }

   switch (self.verticalAlign) {
      case 'top':
        y = 0;
        break;

      case 'bottom':
        y = boxh - h;
        break;

      case 'middle':
      default:
        y = boxh / 2 - h / 2;
        break;
    } 
      
    ctx.drawImage(img, x, y, w, h);
  }

  return obj;
};});

require.define("/node_modules/uijs-controls/node_modules/uijs/package.json",function(require,module,exports,__dirname,__filename,process){module.exports = {"main":"./lib/index"}});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/index.js",function(require,module,exports,__dirname,__filename,process){exports.canvasize = require('./canvasize');
exports.box = require('./box');
exports.html = require('./html');
exports.util = require('./util');
exports.positioning = require('./positioning');
exports.interaction = require('./interaction');
exports.animation = require('./animation');
exports.events = require('./events');

exports.kinetics = require('./kinetics');
exports.scroller = require('./scroller');});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/canvasize.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
var capture = require('./interaction').capture;

module.exports = function(options) {
  options = options || {};

  // we are "DOMfull" if we have a `window` object.
  var domless = (typeof window === 'undefined');

  // by default, start non-paused unless we are domless.
  options.paused = 'paused' in options ? options.paused : domless;

  // by default we do not do auto resize
  options.autoresize = 'autoresize' in options ? options.autoresize : false;

  // shim `window` for DOM-less executions (e.g. node.js)
  if (domless) window = {};

  window.requestAnimationFrame || (
    window.requestAnimationFrame = 
    window.webkitRequestAnimationFrame || 
    window.mozRequestAnimationFrame    || 
    window.oRequestAnimationFrame      || 
    window.msRequestAnimationFrame     || 
    function(cb) { setTimeout(cb, 1000/60); }
  );

  window.devicePixelRatio || (window.devicePixelRatio = 1);

  var canvas = null;

  if (options.element) {
    canvas = options.element;
    canvas.width = canvas.width || parseInt(canvas.style.width) * window.devicePixelRatio;
    canvas.height = canvas.height || parseInt(canvas.style.height) * window.devicePixelRatio;
  }
  else {
    if (typeof document === 'undefined') {
      throw new Error('No DOM. Please pass a Canvas object (e.g. node-canvas) explicitly');
    }

    if (document.body.hasChildNodes()) {
      while (document.body.childNodes.length) {
        document.body.removeChild(document.body.firstChild);
      }
    }

    document.body.style.background = 'rgba(0,0,100,0.0)';
    document.body.style.padding = '0px';
    document.body.style.margin = '0px';

    canvas = document.createElement('canvas');
    canvas.style.background = 'rgba(0,0,0,0.0)';
    document.body.appendChild(canvas);

    function adjust_size() {
      // http://joubert.posterous.com/crisp-html-5-canvas-text-on-mobile-phones-and
      canvas.width = window.innerWidth * window.devicePixelRatio;
      canvas.height = window.innerHeight * window.devicePixelRatio;
      canvas.style.width = window.innerWidth;
      canvas.style.height = window.innerHeight;

      var c = canvas.getContext('2d');
      c.scale(window.devicePixelRatio, window.devicePixelRatio);
    }

    window.onresize = function() {
      if (main && main.autoresize) {
        adjust_size();
      }
    };

    document.body.onorientationchange = function() {
      adjust_size();
    };

    setTimeout(function() { 
      window.scrollTo(0, 0);
      adjust_size();
      window.onresize();
    }, 0);

    adjust_size();
  }

  var ctx = canvas.getContext('2d');

  options = options || {};
  options.id = options.id || 'canvas';
  options.x = options.x || 0;
  options.y = options.y || 0;
  options.width = options.width || function() { return canvas.width / window.devicePixelRatio; };
  options.height = options.height || function() { return canvas.height / window.devicePixelRatio; };

  var main = box(options);

  main.domless = domless;
  main.canvas = canvas;

  // hook canvas events to `main.interact()`.
  capture(canvas, function(event, coords, e) {
    return main.interact(event, coords, e);
  });

  main.paused = options.paused;

  function redraw(force) {
    if (!force && main.paused) return; // stop redraw loop if we are paused.

    //TODO: since the canvas fills the screen we don't really need this?
    if (main.alpha && main.alpha() < 1.0) {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
    }

    main.draw(ctx);

    if (!main.paused) window.requestAnimationFrame(redraw);
  }
  
  if (!main.paused) {
    redraw();
  }

  main.redraw = function() {
    redraw(true);
  };

  main.pause = function() {
    this.paused = true;
  };

  main.resume = function() {
    this.paused = false;
    redraw(); // kick start redraw
  };

  return main;
};});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/box.js",function(require,module,exports,__dirname,__filename,process){var defaults = require('./util').defaults;
var valueof = require('./util').valueof;
var propertize = require('./util').propertize;
var animate = require('./animation');

var EventEmitter = require('./events').EventEmitter;

var idgenerator = 0;


var box = module.exports = function(options) {

  var attributes = defaults(options, {
    x: 0,
    y: 0,
    width: 100,
    height: 100,
    children: [],
    rotation: 0.0,
    visible: true,
    clip: false,
    alpha: null,
    debug: false,
    interaction: true, // send interaction events on this box. must be set to true for events to be emitted
    autopropagate: true, // propagate interaction events to child boxes. if false, the parent needs to call `e.propagate()` on the event
    id: function() { return this._id; },
  });

  // TODO: extend()
  var obj = new EventEmitter();

  for (var k in attributes) {
    obj[k] = attributes[k];
  }

  // turn all attributes except `onxxx` and anything that begins with a '_' to properties.
  propertize(obj, function(attr) {
    return !(attr.indexOf('on') === 0 || attr.indexOf('_') === 0);
  });

  var prev_children = obj.children;

  obj.properties.onchange('children', function(c) {
    var _push = c.push;

    c.forEach(function(i) {
      i.parent = obj;
    });

    c.push = function(child) {
      child.parent = obj;
      return _push.apply(c, arguments);
    };
  });

  obj.children = prev_children;

  obj._id = 'BOX.' + idgenerator++;
  obj._is_box  = true;

  /// ## Box Hierarchy
  /// Boxes have children and parents.

  // returns the root of the box hierarchy
  obj.root = function() {
    var self = this;
    if (!self.parent) return self;
    return self.parent.root();
  };

  // adds a child to the end of the children's stack.
  obj.add = obj.push = function(child) {
    var self = this;
    if (Array.isArray(child)) {
      return child.forEach(function(c) {
        self.add(c);
      });
    }

    if (!box.isbox(child)) {
      throw new Error('can only add boxes as children to a box');
    }

    child.parent = self;
    self.children.push(child);

    return child;
  };

  obj.tofront = function() {
    var self = this;
    if (!self.parent) throw new Error('`tofront` requires that the box will have a parent');
    var parent = self.parent;
    parent.remove(self);
    parent.push(self);
    return self;
  };

  obj.siblings = function() {
    var self = this;
    if (!self.parent) return [ self ]; // detached, no siblings but self
    return self.parent.all();
  };

  obj.prev = function() {
    var self = this;
    if (!self.parent) throw new Error('box must be associated with a parent')
    var children = self.parent.children;
    var my_index = children.indexOf(self);
    if (my_index === 0) return null;
    else return children[my_index - 1];
  };

  // removes a child (or self from parent)
  obj.remove = function(child) {
    var self = this;

    if (!child) {
      if (!self.parent) throw new Error('`remove()` will only work if you have a parent');
      self.parent.remove(self);
      return child;
    }

    var children = self.children;

    var child_index = children.indexOf(child);
    if (child_index === -1) return;
    children.splice(child_index, 1);
    child.parent = null;
    return child;
  };

  // removes all children
  obj.empty = function() {
    var self = this;
    self.children = [];
    return self;
  };

  // retrieve a child by it's `id()` property (or _id). children without
  // this property cannot be retrieved using this function.
  obj.get = function(id) {
    var self = this;
    var result = self.children.filter(function(child) {
      return child.id === id;
    });

    return result.length === 0 ? null : result[0];
  };

  // ### box.query(id)
  // Retrieves a child from the entire box tree by id.
  obj.query = function(id) {
    var self = this;
    var child = self.get(id);
    if (child) return child;

    var children = self.children;
    for (var i = 0; i < children.length; ++i) {
      var child = children[i];
      var result = child.query(id);
      if (result) {
        return result;
      }
    }
  };

  /// ### box.all()
  /// Returns all the children of this box.
  obj.all = function() {
    var self = this;
    return self.children;
  };

  /// ### box.rest([child])
  /// Returns all the children that are not `child` (or do the same on the parent if `child` is null)
  obj.rest = function(child) {
    var self = this;
    if (!child) {
      if (!obj.parent) throw new Error('cannot call `rest()` without a parent');
      return obj.parent.rest(self);
    }

    return self.children.filter(function(c) {
      return c.id !== child.id;
    });
  };

  // returns the first child
  obj.first = function() {
    var self = this;
    return self.children[0];
  };

  // returns a tree representation this box and all it's children
  obj.tree = function(indent) {
    var box = this;
    indent = indent || 0;

    var s = '';
    for (var i = 0; i < indent; ++i) {
      s += ' ';
    }

    s += box.id + '\n';
    
    box.children.forEach(function(child) {
      s += child.tree(indent + 2);
    });

    return s;
  }

  /// ## Drawing

  /// ### box.ondraw(ctx)
  /// `ondraw` is called __every frame__ with a `CanvasRenderingContext2D` as a single
  /// parameter. The box should draw itself as efficiently as possible.
  obj.ondraw = null;

  /// ### box.draw(ctx)
  /// This function is called every frame. It draws the current box (by means of calling `ondraw`)
  /// and then draws the box's children iteratively. This function also implements a few of the basic
  /// drawing capabilities and optimizations: buffering, clipping, scaling, rotation.
  obj.draw = function(ctx) {
    var self = this;

    var children = self.children;

    if (!self.visible || self.alpha === 0.0) return;

    ctx.save();

    if (self.rotation) {
      var centerX = self.x + self.width / 2;
      var centerY = self.y + self.height / 2;
      ctx.translate(centerX, centerY);
      ctx.rotate(self.rotation);
      ctx.translate(-centerX, -centerY);
    }

    // stuff that applies to all children
    ctx.translate(self.x, self.y);
    if (self.alpha) ctx.globalAlpha = self.alpha;

    if (self.clip) {
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(self.width, 0);
      ctx.lineTo(self.width, self.height);
      ctx.lineTo(0, self.height);
      ctx.closePath();
      ctx.clip();
    }

    ctx.save();

    // stuff that applies only to this child

    // emit a `frame` event
    self.emit('frame');

    // call `ondraw` for rendering.
    if (self.ondraw) {
      if (self.width > 0 && self.height > 0) {
        self.ondraw(ctx);
      }
    }

    ctx.restore();

    children.forEach(function(child) {
      //TODO: do not draw child if out of viewport
      child.draw.call(child, ctx);
    });

    ctx.restore();
  };

  // -- interactivity

  // given a `pt` in box coordinates, returns a child
  // that resides in those coordinates. returns { child, child_pt }
  // `filter` is a function that, if returns `false` will ignore a child.
  obj.hittest = function(pt, filter) {
    var self = this;

    if (!pt || !('x' in pt) || !('y' in pt)) return;

    // we go in reverse order because the box stack is based on this.
    var children = self.children.reverse();

    for (var i = 0; i < children.length; ++i) {
      var child = children[i];

      // ignore child if filter is activated
      if (filter && !filter(child)) continue;

      if (pt.x >= child.x &&
          pt.y >= child.y &&
          pt.x <= child.x + child.width &&
          pt.y <= child.y + child.height) {
        
        // convert to child coords
        var child_x = pt.x - child.x;
        var child_y = pt.y - child.y;

        return {
          child: child,
          child_pt: { x: child_x, y: child_y }
        };
      }
    }

    return null;
  };
  
  obj.interact = function(event, pt) {
    var self = this;

    // emit events for all children that required to capture them.
    self._emit_captures(event, pt);

    // if this box does not interaction events, ignore.
    if (!self.interaction) return;

    // queue the event locally to this box (if not capturing)
    if (self.debug) console.log('[' + self.id + ']', event, pt);
    if (!self.capturing()) {
      self.emit(event, pt);
    }

    // nothing to do if `propagate` is false.
    if (self.autopropagate) {
      self.propagate(event, pt);
    }

    // delete all captures that were stopped during this cycle.
    // if we delete them immediately, we get duplicate events if `stopCapture`
    // is called by the event handler (and then self.capturing() is true).
    self._delete_captures();

    return true;
  };

  // propagates an event to any child box that is hit by `pt`.
  // `pt` is in box coordinates and the event is propagated in child coordinates.
  obj.propagate = function(event, pt) {
    var self = this;

    // check if the event should be propagated to one of the children
    var hit = self.hittest(pt, function(child) { return child.interaction; });
    if (hit) {
      return hit.child.interact(event, hit.child_pt);
    }

    return false;
  };

  // returns the screen coordinates of this obj
  obj.screen = function() {
    var self = this;

    if (self.canvas) {
      return {
        x: self.canvas.offsetParent.offsetLeft + self.canvas.offsetLeft,
        y: self.canvas.offsetParent.offsetTop + self.canvas.offsetTop,
      };
    }

    var pscreen = self.parent ? self.parent.screen() : { x: 0, y: 0 };
    return {
      x: pscreen.x + self.x,
      y: pscreen.y + self.y,
    };
  };

  // translates `pt` in the current box's coordinates to `box` coordinates.
  obj.translate = function(pt, box) {
    var boxscreen = box.screen();
    var myscreen = this.screen();
    return {
      x: pt.x + myscreen.x - boxscreen.x,
      y: pt.y + myscreen.y - boxscreen.y,
    };
  };

  // -- capture events

  // emits events to all boxes that called `startCapture`.
  obj._emit_captures = function(event, pt) {
    var self = this;
    if (!self._captures) return; // no captures on this level (only on root)
    for (var id in self._captures) {
      var child = self._captures[id];
      var child_pt = self.translate(pt, child);
      child.emit(event, child_pt);
    }
  };

  // delete all captures that were stopped during this event cycle
  obj._delete_captures = function() {
    var self = this;
    if (!self._captures_to_delete) return;
    if (self._captures) {
      self._captures_to_delete.forEach(function(id) {
        delete self._captures[id];
      });
    }

    self._captures_to_delete = [];
  };

  // registers this box to receive all interaction events until `stopCapture` is called.
  obj.startCapture = function() {
    var root = this.root();
    var captures = root._captures;
    if (!captures) captures = root._captures = {};
    captures[this._id] = this;
  };

  // stops sending all events to this box.
  obj.stopCapture = function() {
    var root = this.root();
    var captures = root._captures;
    if (!captures) return;
    if (!root._captures_to_delete) {
      root._captures_to_delete = [];
    }
    root._captures_to_delete.push(this._id);
  };

  // returns true if events are currently captured by this box.
  obj.capturing = function() {
    var root = this.root();
    var captures = root._captures;
    if (!captures) return false;
    return this._id in captures;
  };

  // -- animation

  obj.animate = function(properties, options) {
    var self = this;
    Object.keys(properties).forEach(function(k) {
      var curr = self[k];
      var target = properties[k];
      if (self.debug) console.log('[' + self.id + ']', 'animating', k, 'from', curr, 'to', target);
      self[k] = animate(curr, target, options);
    });
  };  

  return obj;
};

box.isbox = function(obj) {
  return obj._is_box || obj._is_view;
};});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/util.js",function(require,module,exports,__dirname,__filename,process){var EventEmitter = require('./events').EventEmitter;

exports.min = function(a, b) { return a < b ? a : b; };
exports.max = function(a, b) { return a > b ? a : b; };

// returns a function that creates a new object linked to `this` (`Object.create(this)`).
// any property specified in `options` (if specified) is assigned to the child object.
exports.derive = function(options) {
  return function() {
    var obj = Object.create(this);
    obj.base = this;
    if (options) {
      for (var k in options) {
        obj[k] = options[k];
      }
    }
    return obj;
  };  
};

// returns the value of `obj.property` if it is defined (could be `null` too)
// if not, returns `def` (or false). useful for example in tri-state attributes where `null` 
// is used to disregard it in the drawing process (e.g. `fillStyle`).
exports.valueof = function(obj, property, def) {
  if (!obj) throw new Error('`obj` is required');
  if (!def) def = false;
  if (!(property in obj)) return def;
  else return obj[property];
};

exports.defaults = function(target, source) {
  var valueof = exports.valueof;

  target = target || {};

  for (var k in source) {
    target[k] = valueof(target, k, source[k]);
  }

  return target;
};

exports.loadimage = function(src) {
  if (typeof src === 'function') src = src();
  
  var img = new Image();
  img.src = src;
  img.onload = function() { };

  return function() {
    return img;
  }
};

// turns all attributes of `obj` into functional properties.
// `filter` (`function(attr)`) can be used to filter out any attributes.
exports.propertize = function(obj, filter) {
  filter = filter || function(attr) { return true; }; 

  if (!obj.properties) {
    obj.properties = [];
    obj.properties._ee = new EventEmitter();
    obj.properties.onchange = function(prop, callback) {
      return obj.properties._ee.on(prop, callback);
    };
  }

  function prop(obj, name) {
    var prev = obj[name];

    var curr = null;
    var prev_value = null;

    Object.defineProperty(obj, name, {
      get: function() {
        if (typeof curr === 'function') {
          var new_value = curr.call(this);
          if (new_value !== prev_value){
            obj.properties._ee.emit(name, new_value, prev_value);
          }
          prev_value = new_value;
          return new_value;
        }

        else return curr;
      },
      set: function(value) {
        if (typeof value !== 'function') {
          obj.properties._ee.emit(name, value, curr);
          prev_value = null;
        }

        curr = value;
      }
    });

    obj[name] = prev;
    obj.properties.push(name); // manage a list of property names
  }

  for (var attr in obj) {
    if (!obj.hasOwnProperty(attr)) continue; // skip properties from linked objects
    if (!filter(attr)) continue;
    if (attr === 'properties') continue;
    prop(obj, attr);
  }

  return obj;
};
});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/events.js",function(require,module,exports,__dirname,__filename,process){function EventEmitter() {
  var self = this;
  
  self._subscriptions = {};
  self._pipes = [];

  return self;
}

EventEmitter.prototype.emit = function(event) {
  var self = this;

  var handlers = self._subscriptions[event];
  var original_arguments = arguments;

  var handled;

  if (handlers) {
    var args = [];
    for (var i = 1; i < arguments.length; ++i) {
      args.push(arguments[i]);
    }

    handlers.forEach(function(fn) {
      var ret = fn.apply(self, args);
      if (typeof ret === 'undefined' || ret === true) handled = true;
      if (ret === false) handled = false;
    });
  }


  // emit events on all pipes
  self._pipes.forEach(function(target) {
    var ret = target.emit.apply(target, original_arguments);
    if (typeof ret === 'undefined' || ret === true) handled = true;
    if (ret === false) handled = false;
  });

  return handled;
};

// emits the event (with arguments) after 100ms
// should be used to allow ui to update when emitting
// events from event handlers.
EventEmitter.prototype.queue = function(event) {
  var self = this;
  var args = arguments;
  setTimeout(function() {
    self.emit.apply(self, args);
  }, 5);
};

EventEmitter.prototype.on = function(event, handler) {
  var self = this;
  if (!self._subscriptions) return;
  var handlers = self._subscriptions[event];
  if (!handlers) handlers = self._subscriptions[event] = [];
  handlers.push(handler);

  return self;
};

EventEmitter.prototype.removeAllListeners = function(event) {
  var self = this;
  if (!self._subscriptions) return;
  delete self._subscriptions[event];
  return self;
};

EventEmitter.prototype.removeListener = 
EventEmitter.prototype.off = function(event, handler) {
  var self = this;
  if (!self._subscriptions) return;
  var handlers = self._subscriptions[event];

  var found = -1;
  for (var i = 0; i < handlers.length; ++i) {
    if (handlers[i] === handler) {
      found = i;
    }
  }

  if (found !== -1) {
    handlers.splice(found, 1);
  }

  return self;
};

// forward all events from this EventEmitter to `target`.
EventEmitter.prototype.forward = function(target) {
  var self = this;
  self._pipes.push(target);
  return self;
};

// remove a forward
EventEmitter.prototype.unforward = function(target) {
  var self = this;
  var i = self._pipes.indexOf(target);
  if (i === -1) return false;
  self._pipes.splice(i, 1);
  return true;
};

exports.EventEmitter = EventEmitter;});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/animation.js",function(require,module,exports,__dirname,__filename,process){// -- animation
var curves = exports.curves = {};

curves.linear = function() {
  return function(x) {
    return x;
  };
};

curves.easeInEaseOut = function() {
  return function(x) {
    return (1 - Math.sin(Math.PI / 2 + x * Math.PI)) / 2;
  };
};

module.exports = function(from, to, options) {
  options = options || {};
  options.duration = options.duration || 250;
  options.ondone = options.ondone || function() { };
  options.curve = options.curve || curves.easeInEaseOut();
  options.name = options.name || from.toString() + '_to_' + to.toString();

  var startTime = Date.now();
  var endTime = Date.now() + options.duration;
  var callbackCalled = false;

  return function () {
    var elapsedTime = Date.now() - startTime;
    var ratio = elapsedTime / options.duration;
    if (ratio < 1.0) {
      curr = from + (to - from) * options.curve(ratio);
    }
    else {
      // console.timeEnd(options.name);
      curr = to;
      if (options.ondone && !callbackCalled) {
        options.ondone.call(this);
        callbackCalled = true;
      }
    }
    return curr;
  };
};});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/interaction.js",function(require,module,exports,__dirname,__filename,process){// maps DOM events to uijs event names
var EVENTS = {
  ontouchstart: 'touchstart',
  ontouchmove : 'touchmove',
  ontouchend  : 'touchend',
  onmousedown : 'touchstart',
  onmousemove : 'touchmove',
  onmouseup   : 'touchend',
};

function capture(el, fn) {

  // bind to all mouse/touch interaction events
  Object.keys(EVENTS).forEach(function(k) {
    el[k] = function(e) {
      var name = EVENTS[k];
      e.preventDefault();
      var coords = (name !== 'touchend' || !e.changedTouches) ? relative(e) : relative(e.changedTouches[0]);
      return fn(name, coords, e);
    };
  });

  // get the coordinates for a mouse or touch event
  // http://www.nogginbox.co.uk/blog/canvas-and-multi-touch
  function relative(e) {
    if (e.touches && e.touches.length > 0) {
      e = e.touches[0];
      return { x: e.pageX - el.offsetLeft, y: e.pageY - el.offsetTop };
    }
    else if (e.offsetX) {
      // works in chrome / safari (except on ipad/iphone)
      return { x: e.offsetX, y: e.offsetY };
    }
    else if (e.layerX) {
      // works in Firefox
      return { x: e.layerX, y: e.layerY };
    }
    else if (e.pageX) {
      // works in safari on ipad/iphone
      return { x: e.pageX - el.offsetLeft, y: e.pageY - el.offsetTop };
    }
  }

}

exports.capture = capture;});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/html.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
var util = require('./util');
var capture = require('./interaction').capture;
var defaults = util.defaults;

module.exports = function(options) {
  options = defaults(options, {
    html: '<div>',
    interaction: false, // by default we let HTML capture events
  });

  var obj = box(options);

  var last_bounds = null;

  obj.on('frame', function() {
    var self = this;

    var pt = this.screen();
    var bounds = pt.x + ',' + pt.y + ' ' + this.width + 'x' + this.height;

    if (bounds !== last_bounds) {
      var div = self._container(); // ensure that the element exists.

      // update bounds
      div.style.left = pt.x;
      div.style.top = pt.y;
      div.style.width = this.width;

      // clip to parent bounds or nasty things will happen.
      div.style.height = util.min(this.height, this.parent.height - this.y);

      last_bounds = bounds;
    }
  });

  Object.defineProperty(obj, 'container', {
    get: function() {
      var self = this;
      if (!self._div) return null;
      return self._container();
    },
  })

  // returns the `div` container that hosts this tag.
  // the div will be created and appended to the document body
  // if it ain't.
  obj._container = function() {
    var self = this;
    var div = self._div;
    if (!div) {
      div = self._div = document.createElement('div');
      div.style.overflow = 'auto';
      div.style.position = 'absolute';
      document.body.appendChild(self._div);

      div.innerHTML = self.html;

      if (self.interaction) {
        capture(div, function(event, pt, e) {
          // we need to pass the interaction data to the canvas
          var root = self.root();
          var spt = self.screen();
          root.interact(event, {
            x: pt.x + spt.x,
            y: pt.y + spt.y,
          }, e);
        });
      }

      if (self.onload) {
        self.onload(div);
      }
    }

    return div;
  };

  return obj;
};});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/positioning.js",function(require,module,exports,__dirname,__filename,process){//
// attributes

var attributes = {};

attributes.top = attributes.y = function(box, delta) {
  return function() {
    return box.y + (delta || 0);
  }
};

attributes.left = attributes.x = function(box, delta) { 
  return function() {
    return box.x + (delta || 0);
  }
};

attributes.right = function(box, delta) {
  return function() {
    return box.x + box.width + (delta || 0);
  }
};

attributes.bottom = function(box, delta) {
  return function() {
    return box.y + box.height + (delta || 0);
  };
};

attributes.width = function(box, delta) {
  return function() {
    return box.width + (delta || 0);
  }
};

attributes.height = function(box, delta) {
  return function() {
    return box.height + (delta || 0);
  }
};

attributes.centerx = function(box, delta) {
  return function() {
    return box.width / 2 - this.width / 2 + (delta || 0);
  }
};

attributes.centery = function(box, delta) {
  return function() {
    return box.height / 2 - this.height / 2 + (delta || 0);
  }
};

// export all attributed positional functions
for (var k in attributes) {
  exports[k] = attributes[k];
}

//
// relations

var zero = {
  x: 0,
  y: 0,
  width: 0,
  height: 0,
};

exports.parent = mkrelational(function() {
  if (!this.parent) throw new Error('no parent');
  return this.parent;
});

exports.prev = mkrelational(function() {
  if (!this.parent) throw new Error('no parent no prev()');
  var prev = this.prev();

  // if no prev, it means we are the first, so just assume all 0
  if (!prev) return zero;

  return prev;
});

exports.relative = function(query) {
  return mkrelational(function() {
    var box = this.root().query(query);
    if (!box) return zero;
    return box;
  });
};

// --- private

// returns a hash of positional attributed functions bound to the
// box returned by the `related` function.
function mkrelational(related) {
  if (!related || typeof related !== 'function') throw new Error('`related` must be a function');
  var functions = {};
  Object.keys(attributes).forEach(function(attr) {
    var attrfn = attributes[attr];
    functions[attr] = function(delta) {
      return function() {
        var self = this;
        delta = delta || 0;
        return attrfn(related.call(self), delta).call(self);
      };
    };
  });

  return functions;
}});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/kinetics.js",function(require,module,exports,__dirname,__filename,process){function c(x) { return function() { return x; }; }

function calculateDirection(velocity){
  return Math.abs(velocity) / velocity;
}

function calculateSpeed(v0, acceleration, friction, delta_ts){
  var delta_speed = acceleration * delta_ts;
  return v0 * friction + delta_speed;
}

function calculatePosition(x0, velocity, delta_ts){
  var delta_x = velocity * delta_ts;
  return x0 += delta_x;    
}

function surfaceWithForces(options){
  options = options || {};
  var friction = options.friction || c(0.993);
  var last_ts = Date.now();
  // The time delta for which to calculate the spring action (in seconds). If not set then will take from intervals between calls to the returned function, starting from now
  var delta_ts = options.delta_ts || function(){
    var now = Date.now();
    var calculatedDelta = (now - last_ts) / 1000;
    last_ts = now;
    return calculatedDelta;
  };
  var time_unit = options.time_unit ? options.time_unit() : 0.001; //(In seconds) The calculation will be done for each time unit 
  var acceleration = options.acceleration || c(0);

  var returnValue = {
    position: options.initialPosition ? options.initialPosition() : 0,      
    velocity: options.initialVelocity ? options.initialVelocity() : 0.0, // In pixels per second
    
    animate: function(){
      var self = this;
      var timespan = delta_ts();
      for (var i = 0; i < timespan; i += time_unit) {
        self.velocity = calculateSpeed(self.velocity, acceleration(), friction(), time_unit);
        self.position = calculatePosition(self.position, self.velocity, time_unit);
      }
      return self.position;
    },
  }

  return returnValue;
}

function springAnimation(base, elasticity, options){
  options = options || {};
  var elasticity = options.elasticity || c(65);
  var swf;
  var calculateAcceleration = function(){
    return -((swf.position - base) * elasticity);
  };

  options.friction = options.friction || c(0.995);
  if (options.acceleration) {alert("Cannot define acceleration for a spring, just elasticity and base");};
  options.acceleration = calculateAcceleration;
  var swf = surfaceWithForces(options);

  return swf;    
}

function basicSliderAnimation(options){
  options = options || {};
  options.friction = options.friction || c(0.995);
  return surfaceWithForces(options);
}

function carouselAnimation(carouselleftBase, carouselRightBase, initialPosition, initialVelocity, inSpringMode, initialSpringBase, options){

  options = options || {};
  var elasticity = options.elasticity || c(65);
  var springFriction = options.springFriction || c(0.993);
  var regularFriction = options.regularFriction || c(0.995);
  var springVelocityThreshold = options.springVelocityThreshold || c(300); //Under this velocity (in pixels per sec) the surface will become a spring whose base is the current position
  var time_unit = options.time_unit = options.time_unit || c(0.001); //(In seconds) The calculation will be done for each time unit 
  var last_ts = Date.now();
  // The time delta for which to calculate the spring action (in seconds). If not set then will take from intervals between calls to the returned function, starting from now
  var delta_ts = options.delta_ts || function(){
    var now = Date.now();
    var calculatedDelta = (now - last_ts) / 1000;
    last_ts = now;
    return calculatedDelta;
  };

  var swf;
  var direction = calculateDirection(initialVelocity());
  var nonSpringAcceleration = options.nonSpringAcceleration || function() {return -((swf.velocity / 0.5) + (100 * direction));};

  var determineSpring = function(){
    var leftBase = carouselleftBase();
    var rightBase = carouselRightBase();

    if (swf.position > leftBase) {
      swf.spring = true;
      swf.spring_base = leftBase;
    }
    else if (swf.position < rightBase) {
      swf.spring = true;
      swf.spring_base = rightBase;
    }
    else if (!swf.spring && Math.abs(swf.velocity) < springVelocityThreshold()) {
      swf.spring = true;
      swf.spring_base = swf.position;
    }
  };

  var now = Date.now();
  var options = {
    initialPosition: initialPosition,
    initialVelocity: initialVelocity,
    delta_ts: delta_ts,
    time_unit: time_unit,
    acceleration: function(){
      determineSpring();
      if (swf.spring) {
        return -((swf.position - swf.spring_base) * elasticity());
      }
      else{
        return nonSpringAcceleration();
      }
    },
    friction: function(){  
      determineSpring();
      if (swf.spring) {
        return springFriction();
      }
      else{
        return regularFriction();
      }
    },
  };
  swf = surfaceWithForces(options);
  swf.spring_base = initialSpringBase();
  swf.spring = inSpringMode();
  return swf;
}

function carouselBehavior(spring_left_base, spring_right_base, spring_max_stretch, eventHistory, onClick, options){
  options = options || {};

  var last_touch_position = 0;
  var last_position = 0;
  var last_timestamp;
  var last_speed; // In pixels per second
  var touching = false;
  var moving = false;
  var spring = false;
  var spring_base = 0;

  return function(){
    while (eventHistory.length > 0){
      var oldestEvent = eventHistory.shift();
      var previous_touch_position = last_touch_position;
      last_touch_position = oldestEvent.position;
      var previous_touch_timestamp = last_timestamp;
      last_timestamp = oldestEvent.timestamp;
        
      if (oldestEvent.name === "touchstart") {
        touching = true;
        moving = false;
        spring = false;
      }

      if (oldestEvent.name === "touchmove") {
        touching = true;
        moving = true;
        var delta_position = last_touch_position - previous_touch_position;
        var delta_ts = (last_timestamp - previous_touch_timestamp) / 1000; //In seconds
        if ((last_position > spring_left_base() && delta_position > 0) || (last_position < spring_right_base() && delta_position < 0)) {
          spring = true;
          if (last_position > spring_left_base()) {
            spring_base = spring_left_base();  
          }
          else{
            spring_base = spring_right_base();
          }
          delta_position = (spring_max_stretch() - ((last_position - spring_base) * calculateDirection(delta_position)) ) / spring_max_stretch() * delta_position; 
        }
        else{
          spring = false;
        }
        last_speed = delta_position / delta_ts;
        if(last_speed > 3500){
          last_speed = 3500;
        }

        last_position += delta_position;
      }

      if (oldestEvent.name === "touchend") {
        touching = false;
        if (!moving) { //We've detected a click without a move!!
          console.log('click', previous_touch_position);
          onClick(previous_touch_position, this);
        }
      }
    }
      
    var swf;
    if ((!isNaN(last_speed) && !touching) && moving){
      var now = Date.now();
      options.delta_ts = c((now - last_timestamp) / 1000);
      swf = carouselAnimation(spring_left_base, spring_right_base, c(last_position), c(last_speed), c(spring), c(spring_base), options);
      last_position = swf.animate();
      spring = swf.spring;
      spring_base = swf.spring_base;
      last_timestamp = now;
      last_speed = swf.velocity;
    }

    return last_position;
  }
}

exports.carouselBehavior = carouselBehavior;});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/scroller.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
var kinetics = require('./kinetics');
var defaults = require('./util').defaults;
var min = require('./util').min;
var max = require('./util').max;
var scrollbar = require('./scrollbar');

module.exports = function(options) {
  var obj = box(defaults(options, {
    content: box(),
    clip: true,
  }));

  var bar = scrollbar({ 
    width: function() { return obj.width; },
    height: function() { return obj.height; },
    size: function() {
      return obj.height / obj.content.height;
    },
    position: function() {
      return -obj.content.y / obj.content.height;
    },
  });

  obj.children = function() { 
    return [ obj.content, bar ]; 
  };

  var events = [];

  obj.properties.onchange('content', function(value) {
    value.y = kinetics.carouselBehavior(
      function() { return 0; },
      function() { return obj.height - obj.content.height; },
      function() { return 300; },
      events,
      function() { },
      { regularFriction: function() { return 0.997; } });
  });

  var ts = Date.now();
  var frames = 0;
  
  obj.ondraw = function(ctx) {
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, this.width, this.height);

    var newTime = Date.now();
    frames++;
    if ((newTime - ts) > 1000) {
      console.log("fps: " + frames);
      frames = 0;
      ts = newTime;
    };
  };

  obj.on('touchstart', function(coords) {
    this.startCapture();
    events.push({name: 'touchstart', position: coords.y, timestamp: Date.now()});
  });

  obj.on('touchmove', function(coords) {
    if (!this.capturing()) return;
    events.push({name: 'touchmove', position: coords.y, timestamp: Date.now()});
  });

  obj.on('touchend', function(coords) {
    this.stopCapture();
    events.push({name: 'touchend', position: coords.y, timestamp: Date.now()});
  });

  return obj;
};});

require.define("/node_modules/uijs-controls/node_modules/uijs/lib/scrollbar.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
var defaults = require('./util').defaults;
var min = require('./util').min;
var max = require('./util').max;

module.exports = function(options) {
  var obj = box(defaults(options, {
    position: 0.3,
    size: 0.5,
    interaction: false,
  }));

  obj.ondraw = function(ctx) {
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.5)';
    ctx.lineCap = 'round';
    ctx.lineWidth = 10;
    ctx.beginPath();

    var barstart = 8;
    var barheight = this.height - 16;

    var barposition = this.position * barheight;
    var barsize = this.size * barheight;

    ctx.moveTo(this.width - 10, max(barstart + barposition, barstart));
    ctx.lineTo(this.width - 10, min(barstart + barposition + barsize, barstart + barheight));
    ctx.stroke();
  }; 

  return obj;
};});

require.define("/node_modules/uijs-controls/lib/listView.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
var box = uijs.box;
var util = uijs.util;
var defaults = util.defaults;

module.exports = function(options) {
  var obj = box(defaults(options, {
    borderColor: 'gray',
    borderWidth: 1,
  }));

  obj.items = [];
  var bw = obj.borderWidth;
    
  obj.ondraw = function(ctx) {
    var self = this;

    var relY = (!self.y) ? 0 : self.y;
    //TODO: do not draw child if out of viewport
    Object.keys(self.items).forEach(function(key) {
      var item = self.items[key];

      //update item positioning
      item.x = (!self.x) ? bw : self.x + bw;
      item.y = relY + bw;
      item.width = self.width - bw ;
      item.height = item.height - bw ;
 
      //draw a border
      if(bw > 0)
      {
        ctx.strokeStyle = self.borderColor;
        ctx.lineWidth = bw;
      
        ctx.strokeRect(item.x - bw/2, item.y - bw/2, item.width + bw, item.height + bw);
      }
           
      //call item draw function
      item.draw.call(item, ctx);

      //restore original item height
      item.height = item.height + bw ;
      relY += item.height;  
    });
    
  }

  return obj;
};});

require.define("/node_modules/uijs-controls/lib/button.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
var box = uijs.box;
var util = uijs.util;
var defaults = util.defaults;
var image = require('./image');
var label = require('./label');
var positioning = uijs.positioning;

module.exports = function(options) {

  var obj = image(defaults(options, {
    image: null,
    stretchWidth: true,
    stretchHeight: true,
    width: 100, height: 40,
  }));

  var _ondraw = obj.ondraw;

  obj.alpha = function() { 
    return this._touching ? 0.8 : 1.0;
  };

  obj.add(label({
    x: 0,
    y: 0,
    width: positioning.parent.width(),
    height: positioning.parent.height(),
    color: 'white',
    text: function() { return obj.text; },
    size: function() { return 40/100 * obj.height; },
  }));

  obj.on('touchstart', function() {
    console.log('touch start');
    this._touching = true;
    this.startCapture();
  });

  obj.on('touchend', function(e) {
    console.log('touch end');
    this._touching = false;
    this.stopCapture();
    
    // touchend outside
    if (e.x < 0 || e.x > this.width ||
        e.y < 0 || e.y > this.height) {
      return;
    }

    this.emit('click');
  });

  return obj;
};});

require.define("/node_modules/uijs-controls/lib/label.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
var box = uijs.box;
var util = uijs.util;
var defaults = util.defaults;

module.exports = function(options) {
  var obj = box(defaults(options, {
    text: '',
    size: 20,
    font: 'Helvetica',
    color: 'black',
    border: false,
    shadow: false,
    height: function() { return this.size + 20/100 * this.size },
  }));

  obj.ondraw = function(ctx) {

    if (!this.text) return;

    if (this.border) {
      ctx.strokeStyle = 'yellow';
      ctx.strokeRect(0, 0, this.width, this.height);
    }

    ctx.fillStyle = this.color;
    ctx.font = this.size + 'px ' + this.font;
    
    var m = ctx.measureText(this.text);

    if (this.shadow) {
      ctx.shadowBlur = 2;
      ctx.shadowColor = 'black';
      ctx.shadowOffsetX = 2;
      ctx.shadowOffsetY = 2;
    }

    ctx.fillText(this.text, this.width / 2 - m.width / 2 - 1, this.height / 2 - this.size / 2 + this.size - 20/100 * this.size);
  };

  return obj;
}});

require.define("/station-panel.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
var box = uijs.box;
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');
var animate = uijs.animation;
var positioning = uijs.positioning;
var image = require('uijs-controls').image;
var loadimage = uijs.util.loadimage;
var label = require('uijs-controls').label;
var button = require('uijs-controls').button;

module.exports = function(options) {

  function statusbox(options) {
    var obj = box(defaults(options, {
      width: 121, height: 58,
      count: function() { return 4; },
      icon: loadimage('assets/img/icon_parking.png'),
      status: function() {
        if (this.count === 0) return 'red';
        if (this.count <= 3) return 'yellow';
        else return 'green';
      },
    }));

    var backgrounds = {
      green: loadimage('assets/img/greenbox.png'),
      red: loadimage('assets/img/redbox.png'),
      yellow: loadimage('assets/img/yellowbox.png'),
    };

    var background_image = obj.add(image({
      image: function() { return backgrounds[obj.status](); },
      width: 121, height: 58,
    }));

    var icon_image = obj.add(image({
      image: function() { return obj.icon; },
      width: 121/2, height: 58,
      x: 1, y: 1,
    }));

    var count_label = obj.add(label({
      text: function() { return obj.count; },
      color: 'white',
      size: 40,
      font: 'Helvetica',
      x: positioning.prev.right(), y: positioning.prev.top(5),
      width: 121/2-5,
    }));

    return obj;
  }

  var obj = box(defaults(options, {
    width: 276, height: 167,
    station: {
      name: '108 Rotchild Ave.',
      available_bike: 4,
      available_spaces: 2,
    },
  }));

  var bg = obj.add(image({
    x: 0, y: -6, width: 276, height: 167,
    image: loadimage('assets/img/panel.png'),
  }));

  var name_label = bg.add(label({
    id: '#name',
    x: 10, width: positioning.parent.width(-20),
    y: 10, height: 35,
    size: 20,
    color: 'white',
    shadow: true,
    text: function() {
      return obj.station && obj.station.name;
    }
  }));

  var bike_status = bg.add(statusbox({ 
    id: '#bicycle',
    icon: loadimage('assets/img/icon_bike.png'),
    x: 15, y: positioning.relative('#name').bottom(-4),
    count: function() {
      return obj.station && obj.station.available_bike;
    },
  }));

  var park_status = bg.add(statusbox({ 
    id: '#parking',
    icon: loadimage('assets/img/icon_parking.png'),
    x: positioning.prev.right(), y: positioning.prev.top(),
    count: function() {
      return obj.station && obj.station.available_spaces;
    },
  }));

  var report_button = bg.add(button({
    id: '#report',
    x: function() { return bike_status.x; },
    y: positioning.relative('#parking').bottom(4),
    text: 'Report',
  }));

  var fav_button = bg.add(button({
    id: '#fav',
    x: positioning.relative('#report').right(-1),
    y: positioning.relative('#report').top(),
    image: loadimage('assets/img/button_fav.png'),
    width: 43,
    height: 40,
  }));

  var nav_button = bg.add(button({
    id: '#nav',
    x: positioning.prev.right(-1),
    y: positioning.prev.top(),
    text: 'Navigate',
  }));

  report_button.on('click', function() {
    obj.emit('report', obj.station);
  });

  fav_button.on('click', function() {
    obj.emit('fav', obj.station);
  });

  nav_button.on('click', function() {
    obj.emit('nav', obj.station);
  });

  return obj;
};});

require.define("/model.js",function(require,module,exports,__dirname,__filename,process){var x$ = require('xui');
var EventEmitter = require('uijs').events.EventEmitter;

exports.createModel = function() {

  var obj = new EventEmitter();

  obj.stations = [];

  function reload() {

    x$().xhr('http://telobike.citylifeapps.com/stations', {
      async: true,
      callback: function(items) {
        var stations = JSON.parse(this.responseText);

        console.log('Response with ' + stations.length + ' stations');
        
        stations.forEach(function(s) {
          s.location = [ s.latitude, s.longitude ];
          s.status = determine_status(s);
          s.image = 'assets/img/map_' + s.status + '.png';
          s.center = [ 6.0, -18.0 ];

          // These will create a callout:
          // s.title = s.name;
          // s.subtitle = s.available_bike + ' bicycles ' + s.available_spaces + ' slots';
          // s.icon = 'assets/img/list_' + s.status + '.png';
        });

        var prev = obj.stations;
        obj.stations = stations;
        obj.emit('update', stations, prev);
      },
    });

  }

  function determine_status(station) {
    if (station.available_bike === 0) return 'empty';
    if (station.available_spaces === 0) return 'full';
    if (station.available_bike <= 3) return 'hempty';
    if (station.available_spaces <= 3) return 'hfull';
    return 'okay';
  }

  reload();
  setInterval(reload, 30000); // refresh every 30sec

  return obj;
}

});

require.define("/node_modules/xui/package.json",function(require,module,exports,__dirname,__filename,process){module.exports = {"main":"lib/xui"}});

require.define("/node_modules/xui/lib/xui.js",function(require,module,exports,__dirname,__filename,process){module.exports = require('./xui-2.3.2.js')();});

require.define("/node_modules/xui/lib/xui-2.3.2.js",function(require,module,exports,__dirname,__filename,process){module.exports = function() {

(function () {
/**
	Basics
	======
    
    xui is available as the global `x$` function. It accepts a CSS selector string or DOM element, or an array of a mix of these, as parameters,
    and returns the xui object. For example:
    
        var header = x$('#header'); // returns the element with id attribute equal to "header".
        
    For more information on CSS selectors, see the [W3C specification](http://www.w3.org/TR/CSS2/selector.html). Please note that there are
    different levels of CSS selector support (Levels 1, 2 and 3) and different browsers support each to different degrees. Be warned!
    
	The functions described in the docs are available on the xui object and often manipulate or retrieve information about the elements in the
	xui collection.

*/
var undefined,
    xui,
    window     = this,
    string     = new String('string'), // prevents Goog compiler from removing primative and subsidising out allowing us to compress further
    document   = window.document,      // obvious really
    simpleExpr = /^#?([\w-]+)$/,   // for situations of dire need. Symbian and the such        
    idExpr     = /^#/,
    tagExpr    = /<([\w:]+)/, // so you can create elements on the fly a la x$('<img href="/foo" /><strong>yay</strong>')
    slice      = function (e) { return [].slice.call(e, 0); };
    try { var a = slice(document.documentElement.childNodes)[0].nodeType; }
    catch(e){ slice = function (e) { var ret=[]; for (var i=0; e[i]; i++) ret.push(e[i]); return ret; }; }

window.x$ = window.xui = xui = function(q, context) {
    return new xui.fn.find(q, context);
};

// patch in forEach to help get the size down a little and avoid over the top currying on event.js and dom.js (shortcuts)
if (! [].forEach) {
    Array.prototype.forEach = function(fn) {
        var len = this.length || 0,
            i = 0,
            that = arguments[1]; // wait, what's that!? awwww rem. here I thought I knew ya!
                                 // @rem - that that is a hat tip to your thats :)

        if (typeof fn == 'function') {
            for (; i < len; i++) {
                fn.call(that, this[i], i, this);
            }
        }
    };
}
/*
 * Array Remove - By John Resig (MIT Licensed) 
 */
function removex(array, from, to) {
    var rest = array.slice((to || from) + 1 || array.length);
    array.length = from < 0 ? array.length + from: from;
    return array.push.apply(array, rest);
}

// converts all CSS style names to DOM style names, i.e. margin-left to marginLeft
function domstyle(name) {
  return name.replace(/\-[a-z]/g,function(m) { return m[1].toUpperCase(); });
}

// converts all DOM style names to CSS style names, i.e. marginLeft to margin-left
function cssstyle(name) {
  return name.replace(/[A-Z]/g, function(m) { return '-'+m.toLowerCase(); })
}

xui.fn = xui.prototype = {

/**
	extend
	------

	Extends XUI's prototype with the members of another object.

	### syntax ###

		xui.extend( object );

	### arguments ###

	- object `Object` contains the members that will be added to XUI's prototype.
 
	### example ###

	Given:

		var sugar = {
		    first: function() { return this[0]; },
		    last:  function() { return this[this.length - 1]; }
		}

	We can extend xui's prototype with members of `sugar` by using `extend`:

		xui.extend(sugar);

	Now we can use `first` and `last` in all instances of xui:

		var f = x$('.button').first();
		var l = x$('.notice').last();
*/
    extend: function(o) {
        for (var i in o) {
            xui.fn[i] = o[i];
        }
    },

/**
	find
	----

	Find the elements that match a query string. `x$` is an alias for `find`.

	### syntax ###

		x$( window ).find( selector, context );

	### arguments ###

	- selector `String` is a CSS selector that will query for elements.
	- context `HTMLElement` is the parent element to search from _(optional)_.
 
	### example ###

	Given the following markup:

		<ul id="first">
		    <li id="one">1</li>
		    <li id="two">2</li>
		</ul>
		<ul id="second">
		    <li id="three">3</li>
		    <li id="four">4</li>
		</ul>

	We can select list items using `find`:

		x$('li');                 // returns all four list item elements.
		x$('#second').find('li'); // returns list items "three" and "four"
*/
    find: function(q, context) {
        var ele = [], tempNode;
            
        if (!q) {
            return this;
        } else if (context == undefined && this.length) {
            ele = this.each(function(el) {
                ele = ele.concat(slice(xui(q, el)));
            }).reduce(ele);
        } else {
            context = context || document;
            // fast matching for pure ID selectors and simple element based selectors
            if (typeof q == string) {
              if (simpleExpr.test(q) && context.getElementById && context.getElementsByTagName) {
                  ele = idExpr.test(q) ? [context.getElementById(q.substr(1))] : context.getElementsByTagName(q);
                  // nuke failed selectors
                  if (ele[0] == null) { 
                    ele = [];
                  }
              // match for full html tags to create elements on the go
              } else if (tagExpr.test(q)) {
                  tempNode = document.createElement('i');
                  tempNode.innerHTML = q;
                  slice(tempNode.childNodes).forEach(function (el) {
                    ele.push(el);
                  });
              } else {
                  // one selector, check if Sizzle is available and use it instead of querySelectorAll.
                  if (window.Sizzle !== undefined) {
                    ele = Sizzle(q, context);
                  } else {
                    ele = context.querySelectorAll(q);
                  }
              }
              // blanket slice
              ele = slice(ele);
            } else if (q instanceof Array) {
                ele = q;
            } else if (q.nodeName || q === window) { // only allows nodes in
                // an element was passed in
                ele = [q];
            } else if (q.toString() == '[object NodeList]' ||
q.toString() == '[object HTMLCollection]' || typeof q.length == 'number') {
                ele = slice(q);
            }
        }
        // disabling the append style, could be a plugin (found in more/base):
        // xui.fn.add = function (q) { this.elements = this.elements.concat(this.reduce(xui(q).elements)); return this; }
        return this.set(ele);
    },

/**
	set
	---

	Sets the objects in the xui collection.

	### syntax ###

		x$( window ).set( array );
*/
    set: function(elements) {
        var ret = xui();
        ret.cache = slice(this.length ? this : []);
        ret.length = 0;
        [].push.apply(ret, elements);
        return ret;
    },

/**
	reduce
	------

	Reduces the set of elements in the xui object to a unique set.

	### syntax ###

		x$( window ).reduce( elements, index );

	### arguments ###

	- elements `Array` is an array of elements to reduce _(optional)_.
	- index `Number` is the last array index to include in the reduction. If unspecified, it will reduce all elements _(optional)_.
*/
    reduce: function(elements, b) {
        var a = [],
        elements = elements || slice(this);
        elements.forEach(function(el) {
            // question the support of [].indexOf in older mobiles (RS will bring up 5800 to test)
            if (a.indexOf(el, 0, b) < 0)
            a.push(el);
        });

        return a;
    },

/**
	has
	---

	Returns the elements that match a given CSS selector.

	### syntax ###

		x$( window ).has( selector );

	### arguments ###

	- selector `String` is a CSS selector that will match all children of the xui collection.

	### example ###

	Given:

		<div>
		    <div class="round">Item one</div>
		    <div class="round">Item two</div>
		</div>
	
	We can use `has` to select specific objects:

		var divs    = x$('div');          // got all three divs.
		var rounded = divs.has('.round'); // got two divs with the class .round
*/
     has: function(q) {
         var list = xui(q);
         return this.filter(function () {
             var that = this;
             var found = null;
             list.each(function (el) {
                 found = (found || el == that);
             });
             return found;
         });
     },

/**
	filter
	------

	Extend XUI with custom filters. This is an interal utility function, but is also useful to developers.

	### syntax ###

		x$( window ).filter( fn );

	### arguments ###

	- fn `Function` is called for each element in the XUI collection.

	        // `index` is the array index of the current element
	        function( index ) {
	            // `this` is the element iterated on
	            // return true to add element to new XUI collection
	        }

	### example ###

	Filter all the `<input />` elements that are disabled:

		x$('input').filter(function(index) {
		    return this.checked;
		});
*/
    filter: function(fn) {
        var elements = [];
        return this.each(function(el, i) {
            if (fn.call(el, i)) elements.push(el);
        }).set(elements);
    },

/**
	not
	---

	The opposite of `has`. It modifies the elements and returns all of the elements that do __not__ match a CSS query.

	### syntax ###

		x$( window ).not( selector );

	### arguments ###

	- selector `String` a CSS selector for the elements that should __not__ be matched.

	### example ###

	Given:

		<div>
		    <div class="round">Item one</div>
		    <div class="round">Item two</div>
		    <div class="square">Item three</div>
		    <div class="shadow">Item four</div>
		</div>

	We can use `not` to select objects:

		var divs     = x$('div');          // got all four divs.
		var notRound = divs.not('.round'); // got two divs with classes .square and .shadow
*/
    not: function(q) {
        var list = slice(this),
            omittedNodes = xui(q);
        if (!omittedNodes.length) {
            return this;
        }
        return this.filter(function(i) {
            var found;
            omittedNodes.each(function(el) {
                return found = list[i] != el;
            });
            return found;
        });
    },

/**
	each
	----

	Element iterator for an XUI collection.

	### syntax ###

		x$( window ).each( fn )

	### arguments ###

	- fn `Function` callback that is called once for each element.

		    // `element` is the current element
		    // `index` is the element index in the XUI collection
		    // `xui` is the XUI collection.
		    function( element, index, xui ) {
		        // `this` is the current element
		    }

	### example ###

		x$('div').each(function(element, index, xui) {
		    alert("Here's the " + index + " element: " + element);
		});
*/
    each: function(fn) {
        // we could compress this by using [].forEach.call - but we wouldn't be able to support
        // fn return false breaking the loop, a feature I quite like.
        for (var i = 0, len = this.length; i < len; ++i) {
            if (fn.call(this[i], this[i], i, this) === false)
            break;
        }
        return this;
    }
};

xui.fn.find.prototype = xui.fn;
xui.extend = xui.fn.extend;
/**
	DOM
	===

	Set of methods for manipulating the Document Object Model (DOM).

*/
xui.extend({
/**
	html
	----

	Manipulates HTML in the DOM. Also just returns the inner HTML of elements in the collection if called with no arguments.

	### syntax ###

		x$( window ).html( location, html );

	or this method will accept just a HTML fragment with a default behavior of inner:

		x$( window ).html( html );

	or you can use shorthand syntax by using the location name argument as the function name:

		x$( window ).outer( html );
		x$( window ).before( html );
	
	or you can just retrieve the inner HTML of elements in the collection with:
	
	    x$( document.body ).html();

	### arguments ###

	- location `String` can be one of: _inner_, _outer_, _top_, _bottom_, _remove_, _before_ or _after_.
	- html `String` is a string of HTML markup or a `HTMLElement`.

	### example ###

		x$('#foo').html('inner', '<strong>rock and roll</strong>');
		x$('#foo').html('outer', '<p>lock and load</p>');
		x$('#foo').html('top',   '<div>bangers and mash</div>');
		x$('#foo').html('bottom','<em>mean and clean</em>');
		x$('#foo').html('remove');
		x$('#foo').html('before', '<p>some warmup html</p>');
		x$('#foo').html('after',  '<p>more html!</p>');

	or

		x$('#foo').html('<p>sweet as honey</p>');
		x$('#foo').outer('<p>free as a bird</p>');
		x$('#foo').top('<b>top of the pops</b>');
		x$('#foo').bottom('<span>bottom of the barrel</span>');
		x$('#foo').before('<pre>first in line</pre>');
		x$('#foo').after('<marquee>better late than never</marquee>');
*/
    html: function(location, html) {
        clean(this);

        if (arguments.length == 0) {
            var i = [];
            this.each(function(el) {
                i.push(el.innerHTML);
            });
            return i;
        }
        if (arguments.length == 1 && arguments[0] != 'remove') {
            html = location;
            location = 'inner';
        }
        if (location != 'remove' && html && html.each !== undefined) {
            if (location == 'inner') {
                var d = document.createElement('p');
                html.each(function(el) {
                    d.appendChild(el);
                });
                this.each(function(el) {
                    el.innerHTML = d.innerHTML;
                });
            } else {
                var that = this;
                html.each(function(el){
                    that.html(location, el);
                });
            }
            return this;
        }
        return this.each(function(el) {
            var parent, 
                list, 
                len, 
                i = 0;
            if (location == "inner") { // .html
                if (typeof html == string || typeof html == "number") {
                    el.innerHTML = html;
                    list = el.getElementsByTagName('SCRIPT');
                    len = list.length;
                    for (; i < len; i++) {
                        eval(list[i].text);
                    }
                } else {
                    el.innerHTML = '';
                    el.appendChild(html);
                }
            } else {
              if (location == 'remove') {
                el.parentNode.removeChild(el);
              } else {
                var elArray = ['outer', 'top', 'bottom'],
                    wrappedE = wrapHelper(html, (elArray.indexOf(location) > -1 ? el : el.parentNode )),
                    children = wrappedE.childNodes;
                if (location == "outer") { // .replaceWith
                  el.parentNode.replaceChild(wrappedE, el);
                } else if (location == "top") { // .prependTo
                    el.insertBefore(wrappedE, el.firstChild);
                } else if (location == "bottom") { // .appendTo
                    el.insertBefore(wrappedE, null);
                } else if (location == "before") { // .insertBefore
                    el.parentNode.insertBefore(wrappedE, el);
                } else if (location == "after") { // .insertAfter
                    el.parentNode.insertBefore(wrappedE, el.nextSibling);
                }
                var parent = wrappedE.parentNode;
                while(children.length) {
                  parent.insertBefore(children[0], wrappedE);
                }
                parent.removeChild(wrappedE);
              }
            }
        });
    },

/**
	attr
	----

	Gets or sets attributes on elements. If getting, returns an array of attributes matching the xui element collection's indices.

	### syntax ###

		x$( window ).attr( attribute, value );

	### arguments ###

	- attribute `String` is the name of HTML attribute to get or set.
	- value `Varies` is the value to set the attribute to. Do not use to get the value of attribute _(optional)_.

	### example ###

	To get an attribute value, simply don't provide the optional second parameter:

		x$('.someClass').attr('class');

	To set an attribute, use both parameters:

		x$('.someClass').attr('disabled', 'disabled');
*/
    attr: function(attribute, val) {
        if (arguments.length == 2) {
            return this.each(function(el) {
                if (el.tagName && el.tagName.toLowerCase() == 'input' && attribute == 'value') el.value = val;
                else if (el.setAttribute) {
                  if (attribute == 'checked' && (val == '' || val == false || typeof val == "undefined")) el.removeAttribute(attribute);
                  else el.setAttribute(attribute, val);
                }
            });
        } else {
            var attrs = [];
            this.each(function(el) {
                if (el.tagName && el.tagName.toLowerCase() == 'input' && attribute == 'value') attrs.push(el.value);
                else if (el.getAttribute && el.getAttribute(attribute)) {
                    attrs.push(el.getAttribute(attribute));
                }
            });
            return attrs;
        }
    }
});
"inner outer top bottom remove before after".split(' ').forEach(function (method) {
  xui.fn[method] = function(where) { return function (html) { return this.html(where, html); }; }(method);
});
// private method for finding a dom element
function getTag(el) {
    return (el.firstChild === null) ? {'UL':'LI','DL':'DT','TR':'TD'}[el.tagName] || el.tagName : el.firstChild.tagName;
}

function wrapHelper(html, el) {
  if (typeof html == string) return wrap(html, getTag(el));
  else { var e = document.createElement('div'); e.appendChild(html); return e; }
}

// private method
// Wraps the HTML in a TAG, Tag is optional
// If the html starts with a Tag, it will wrap the context in that tag.
function wrap(xhtml, tag) {
  var e = document.createElement('div');
  e.innerHTML = xhtml;
  return e;
}

/*
* Removes all erronious nodes from the DOM.
* 
*/
function clean(collection) {
    var ns = /\S/;
    collection.each(function(el) {
        var d = el,
            n = d.firstChild,
            ni = -1,
            nx;
        while (n) {
            nx = n.nextSibling;
            if (n.nodeType == 3 && !ns.test(n.nodeValue)) {
                d.removeChild(n);
            } else {
                n.nodeIndex = ++ni; // FIXME not sure what this is for, and causes IE to bomb (the setter) - @rem
            }
            n = nx;
        }
    });
}
/**
	Event
	=====

	A good old fashioned events with new skool handling. Shortcuts exist for:

	- click
	- load
	- touchstart
	- touchmove
	- touchend
	- touchcancel
	- gesturestart
	- gesturechange
	- gestureend
	- orientationchange
	
*/
xui.events = {}; var cache = {};
xui.extend({

/**
	on
	--

	Registers a callback function to a DOM event on the element collection.

	### syntax ###

		x$( 'button' ).on( type, fn );

	or

		x$( 'button' ).click( fn );

	### arguments ###

	- type `String` is the event to subscribe (e.g. _load_, _click_, _touchstart_, etc).
	- fn `Function` is a callback function to execute when the event is fired.

	### example ###

		x$( 'button' ).on( 'click', function(e) {
		    alert('hey that tickles!');
		});

	or

		x$(window).load(function(e) {
		  x$('.save').touchstart( function(evt) { alert('tee hee!'); }).css(background:'grey');
		});
*/
    on: function(type, fn, details) {
        return this.each(function (el) {
            if (xui.events[type]) {
                var id = _getEventID(el), 
                    responders = _getRespondersForEvent(id, type);
                
                details = details || {};
                details.handler = function (event, data) {
                    xui.fn.fire.call(xui(this), type, data);
                };
                
                // trigger the initialiser - only happens the first time around
                if (!responders.length) {
                    xui.events[type].call(el, details);
                }
            } 
            el.addEventListener(type, _createResponder(el, type, fn), false);
        });
    },

/**
	un
	--

	Unregisters a specific callback, or if no specific callback is passed in, 
	unregisters all event callbacks of a specific type.

	### syntax ###

	Unregister the given function, for the given type, on all button elements:

		x$( 'button' ).un( type, fn );

	Unregisters all callbacks of the given type, on all button elements:

		x$( 'button' ).un( type );

	### arguments ###

	- type `String` is the event to unsubscribe (e.g. _load_, _click_, _touchstart_, etc).
	- fn `Function` is the callback function to unsubscribe _(optional)_.

	### example ###

		// First, create a click event that display an alert message
		x$('button').on('click', function() {
		    alert('hi!');
		});
		
		// Now unsubscribe all functions that response to click on all button elements
		x$('button').un('click');

	or

		var greeting = function() { alert('yo!'); };
		
		x$('button').on('click', greeting);
		x$('button').on('click', function() {
		    alert('hi!');
		});
		
		// When any button is clicked, the 'hi!' message will fire, but not the 'yo!' message.
		x$('button').un('click', greeting);
*/
    un: function(type, fn) {
        return this.each(function (el) {
            var id = _getEventID(el), responders = _getRespondersForEvent(id, type), i = responders.length;

            while (i--) {
                if (fn === undefined || fn.guid === responders[i].guid) {
                    el.removeEventListener(type, responders[i], false);
                    removex(cache[id][type], i, 1);
                }
            }

            if (cache[id][type].length === 0) delete cache[id][type];
            for (var t in cache[id]) {
                return;
            }
            delete cache[id];
        });
    },

/**
	fire
	----

	Triggers a specific event on the xui collection.

	### syntax ###

		x$( selector ).fire( type, data );

	### arguments ###

	- type `String` is the event to fire (e.g. _load_, _click_, _touchstart_, etc).
	- data `Object` is a JSON object to use as the event's `data` property.

	### example ###

		x$('button#reset').fire('click', { died:true });
		
		x$('.target').fire('touchstart');
*/
    fire: function (type, data) {
        return this.each(function (el) {
            if (el == document && !el.dispatchEvent)
                el = document.documentElement;

            var event = document.createEvent('HTMLEvents');
            event.initEvent(type, true, true);
            event.data = data || {};
            event.eventName = type;
          
            el.dispatchEvent(event);
  	    });
  	}
});

"click load submit touchstart touchmove touchend touchcancel gesturestart gesturechange gestureend orientationchange".split(' ').forEach(function (event) {
  xui.fn[event] = function(action) { return function (fn) { return fn ? this.on(action, fn) : this.fire(action); }; }(event);
});

// patched orientation support - Andriod 1 doesn't have native onorientationchange events
xui(window).on('load', function() {
    if (!('onorientationchange' in document.body)) {
      (function (w, h) {
        xui(window).on('resize', function () {
          var portraitSwitch = (window.innerWidth < w && window.innerHeight > h) && (window.innerWidth < window.innerHeight),
              landscapeSwitch = (window.innerWidth > w && window.innerHeight < h) && (window.innerWidth > window.innerHeight);
          if (portraitSwitch || landscapeSwitch) {
            window.orientation = portraitSwitch ? 0 : 90; // what about -90? Some support is better than none
            xui('body').fire('orientationchange'); // will this bubble up?
            w = window.innerWidth;
            h = window.innerHeight;
          }
        });
      })(window.innerWidth, window.innerHeight);
    }
});

// this doesn't belong on the prototype, it belongs as a property on the xui object
xui.touch = (function () {
  try{
    return !!(document.createEvent("TouchEvent").initTouchEvent)
  } catch(e) {
    return false;
  };
})();

/**
	ready
	----

  Event handler for when the DOM is ready. Thank you [domready](http://www.github.com/ded/domready)!

	### syntax ###

		x$.ready(handler);

	### arguments ###

	- handler `Function` event handler to be attached to the "dom is ready" event.

	### example ###

    x$.ready(function() {
      alert('mah doms are ready');
    });

    xui.ready(function() {
      console.log('ready, set, go!');
    });
*/
xui.ready = function(handler) {
  domReady(handler);
}

// lifted from Prototype's (big P) event model
function _getEventID(element) {
    if (element._xuiEventID) return element._xuiEventID;
    return element._xuiEventID = ++_getEventID.id;
}

_getEventID.id = 1;

function _getRespondersForEvent(id, eventName) {
    var c = cache[id] = cache[id] || {};
    return c[eventName] = c[eventName] || [];
}

function _createResponder(element, eventName, handler) {
    var id = _getEventID(element), r = _getRespondersForEvent(id, eventName);

    var responder = function(event) {
        if (handler.call(element, event) === false) {
            event.preventDefault();
            event.stopPropagation();
        }
    };
    
    responder.guid = handler.guid = handler.guid || ++_getEventID.id;
    responder.handler = handler;
    r.push(responder);
    return responder;
}
/**
	Fx
	==

	Animations, transforms, and transitions for getting the most out of hardware accelerated CSS.

*/

xui.extend({

/**
	Tween
	-----

	Transforms a CSS property's value.

	### syntax ###

		x$( selector ).tween( properties, callback );

	### arguments ###

	- properties `Object` or `Array` of CSS properties to tween.
	    - `Object` is a JSON object that defines the CSS properties.
	    - `Array` is a `Object` set that is tweened sequentially.
	- callback `Function` to be called when the animation is complete. _(optional)_.

	### properties ###

	A property can be any CSS style, referenced by the JavaScript notation.

	A property can also be an option from [emile.js](https://github.com/madrobby/emile):

	- duration `Number` of the animation in milliseconds.
	- after `Function` is called after the animation is finished.
	- easing `Function` allows for the overriding of the built-in animation function.

			// Receives one argument `pos` that indicates position
			// in time between animation's start and end.
			function(pos) {
			    // return the new position
			    return (-Math.cos(pos * Math.PI) / 2) + 0.5;
			}

	### example ###

		// one JSON object
		x$('#box').tween({ left:'100px', backgroundColor:'blue' });
		x$('#box').tween({ left:'100px', backgroundColor:'blue' }, function() {
		    alert('done!');
		});
		
		// array of two JSON objects
		x$('#box').tween([{left:'100px', backgroundColor:'green', duration:.2 }, { right:'100px' }]); 
*/
	tween: function( props, callback ) {

    // creates an options obj for emile
    var emileOpts = function(o) {
      var options = {};
      "duration after easing".split(' ').forEach( function(p) {
        if (props[p]) {
            options[p] = props[p];
            delete props[p];
        }
      });
      return options;
    }

    // serialize the properties into a string for emile
    var serialize = function(props) {
      var serialisedProps = [], key;
      if (typeof props != string) {
        for (key in props) {
          serialisedProps.push(cssstyle(key) + ':' + props[key]);
        }
        serialisedProps = serialisedProps.join(';');
      } else {
        serialisedProps = props;
      }
      return serialisedProps;
    };

    // queued animations
    /* wtf is this?
		if (props instanceof Array) {
		    // animate each passing the next to the last callback to enqueue
		    props.forEach(function(a){
		      
		    });
		}
    */
    // this branch means we're dealing with a single tween
    var opts = emileOpts(props);
    var prop = serialize(props);
		
		return this.each(function(e){
			emile(e, prop, opts, callback);
		});
	}
});
/**
	Style
	=====

	Everything related to appearance. Usually, this is CSS.

*/
function hasClass(el, className) {
    return getClassRegEx(className).test(el.className);
}

// Via jQuery - used to avoid el.className = ' foo';
// Used for trimming whitespace
var rtrim = /^(\s|\u00A0)+|(\s|\u00A0)+$/g;

function trim(text) {
  return (text || "").replace( rtrim, "" );
}

xui.extend({
/**
	setStyle
	--------

	Sets the value of a single CSS property.

	### syntax ###

		x$( selector ).setStyle( property, value );

	### arguments ###

	- property `String` is the name of the property to modify.
	- value `String` is the new value of the property.

	### example ###

		x$('.flash').setStyle('color', '#000');
		x$('.button').setStyle('backgroundColor', '#EFEFEF');
*/
    setStyle: function(prop, val) {
        prop = domstyle(prop);
        return this.each(function(el) {
            el.style[prop] = val;
        });
    },

/**
	getStyle
	--------

	Returns the value of a single CSS property. Can also invoke a callback to perform more specific processing tasks related to the property value.
	Please note that the return type is always an Array of strings. Each string corresponds to the CSS property value for the element with the same index in the xui collection.

	### syntax ###

		x$( selector ).getStyle( property, callback );

	### arguments ###

	- property `String` is the name of the CSS property to get.
	- callback `Function` is called on each element in the collection and passed the property _(optional)_.

	### example ###
        <ul id="nav">
            <li class="trunk" style="font-size:12px;background-color:blue;">hi</li>
            <li style="font-size:14px;">there</li>
        </ul>
        
		x$('ul#nav li.trunk').getStyle('font-size'); // returns ['12px']
		x$('ul#nav li.trunk').getStyle('fontSize'); // returns ['12px']
		x$('ul#nav li').getStyle('font-size'); // returns ['12px', '14px']
		
		x$('ul#nav li.trunk').getStyle('backgroundColor', function(prop) {
		    alert(prop); // alerts 'blue' 
		});
*/
    getStyle: function(prop, callback) {
        // shortcut getComputedStyle function
        var s = function(el, p) {
            // this *can* be written to be smaller - see below, but in fact it doesn't compress in gzip as well, the commented
            // out version actually *adds* 2 bytes.
            // return document.defaultView.getComputedStyle(el, "").getPropertyValue(p.replace(/([A-Z])/g, "-$1").toLowerCase());
            return document.defaultView.getComputedStyle(el, "").getPropertyValue(cssstyle(p));
        }
        if (callback === undefined) {
        	var styles = [];
          this.each(function(el) {styles.push(s(el, prop))});
          return styles;
        } else return this.each(function(el) { callback(s(el, prop)); });
    },

/**
	addClass
	--------

	Adds a class to all of the elements in the collection.

	### syntax ###

		x$( selector ).addClass( className );

	### arguments ###

	- className `String` is the name of the CSS class to add.

	### example ###

		x$('.foo').addClass('awesome');
*/
    addClass: function(className) {
        var cs = className.split(' ');
        return this.each(function(el) {
            cs.forEach(function(clazz) {
              if (hasClass(el, clazz) === false) {
                el.className = trim(el.className + ' ' + clazz);
              }
            });
        });
    },

/**
	hasClass
	--------

	Checks if the class is on _all_ elements in the xui collection.

	### syntax ###

		x$( selector ).hasClass( className, fn );

	### arguments ###

	- className `String` is the name of the CSS class to find.
	- fn `Function` is a called for each element found and passed the element _(optional)_.

			// `element` is the HTMLElement that has the class
			function(element) {
			    console.log(element);
			}

	### example ###
        <div id="foo" class="foo awesome"></div>
        <div class="foo awesome"></div>
        <div class="foo"></div>
        
		// returns true
		x$('#foo').hasClass('awesome');
		
		// returns false (not all elements with class 'foo' have class 'awesome'),
		// but the callback gets invoked with the elements that did match the 'awesome' class
		x$('.foo').hasClass('awesome', function(element) {
		    console.log('Hey, I found: ' + element + ' with class "awesome"');
		});
		
		// returns true (all DIV elements have the 'foo' class)
		x$('div').hasClass('foo');
*/
    hasClass: function(className, callback) {
        var self = this,
            cs = className.split(' ');
        return this.length && (function() {
                var hasIt = true;
                self.each(function(el) {
                  cs.forEach(function(clazz) {
                    if (hasClass(el, clazz)) {
                        if (callback) callback(el);
                    } else hasIt = false;
                  });
                });
                return hasIt;
            })();
    },

/**
	removeClass
	-----------

	Removes the specified class from all elements in the collection. If no class is specified, removes all classes from the collection.

	### syntax ###

		x$( selector ).removeClass( className );

	### arguments ###

	- className `String` is the name of the CSS class to remove. If not specified, then removes all classes from the matched elements. _(optional)_

	### example ###

		x$('.foo').removeClass('awesome');
*/
    removeClass: function(className) {
        if (className === undefined) this.each(function(el) { el.className = ''; });
        else {
          var cs = className.split(' ');
          this.each(function(el) {
            cs.forEach(function(clazz) {
              el.className = trim(el.className.replace(getClassRegEx(clazz), '$1'));
            });
          });
        }
        return this;
    },

/**
	toggleClass
	-----------

	Removes the specified class if it exists on the elements in the xui collection, otherwise adds it. 

	### syntax ###

		x$( selector ).toggleClass( className );

	### arguments ###

	- className `String` is the name of the CSS class to toggle.

	### example ###
        <div class="foo awesome"></div>
        
		x$('.foo').toggleClass('awesome'); // div above loses its awesome class.
*/
    toggleClass: function(className) {
        var cs = className.split(' ');
        return this.each(function(el) {
            cs.forEach(function(clazz) {
              if (hasClass(el, clazz)) el.className = trim(el.className.replace(getClassRegEx(clazz), '$1'));
              else el.className = trim(el.className + ' ' + clazz);
            });
        });
    },
    
/**
	css
	---

	Set multiple CSS properties at once.

	### syntax ###

		x$( selector ).css( properties );

	### arguments ###

	- properties `Object` is a JSON object that defines the property name/value pairs to set.

	### example ###

		x$('.foo').css({ backgroundColor:'blue', color:'white', border:'2px solid red' });
*/
    css: function(o) {
        for (var prop in o) {
            this.setStyle(prop, o[prop]);
        }
        return this;
    }
});

// RS: now that I've moved these out, they'll compress better, however, do these variables
// need to be instance based - if it's regarding the DOM, I'm guessing it's better they're
// global within the scope of xui

// -- private methods -- //
var reClassNameCache = {},
    getClassRegEx = function(className) {
        var re = reClassNameCache[className];
        if (!re) {
            // Preserve any leading whitespace in the match, to be used when removing a class
            re = new RegExp('(^|\\s+)' + className + '(?:\\s+|$)');
            reClassNameCache[className] = re;
        }
        return re;
    };
/**
	XHR
	===

	Everything related to remote network connections.

 */
xui.extend({	
/**
	xhr
	---

	The classic `XMLHttpRequest` sometimes also known as the Greek hero: _Ajax_. Not to be confused with _AJAX_ the cleaning agent.

	### detail ###

	This method has a few new tricks.

	It is always invoked on an element collection and uses the behaviour of `html`.

	If there is no callback, then the `responseText` will be inserted into the elements in the collection.

	### syntax ###

		x$( selector ).xhr( location, url, options )

	or accept a url with a default behavior of inner:

		x$( selector ).xhr( url, options );

	or accept a url with a callback:
	
		x$( selector ).xhr( url, fn );

	### arguments ###

	- location `String` is the location to insert the `responseText`. See `html` for values.
	- url `String` is where to send the request.
	- fn `Function` is called on status 200 (i.e. success callback).
	- options `Object` is a JSON object with one or more of the following:
		- method `String` can be _get_, _put_, _delete_, _post_. Default is _get_.
		- async `Boolean` enables an asynchronous request. Defaults to _false_.
		- data `String` is a url encoded string of parameters to send.
                - error `Function` is called on error or status that is not 200. (i.e. failure callback).
		- callback `Function` is called on status 200 (i.e. success callback).
    - headers `Object` is a JSON object with key:value pairs that get set in the request's header set.

	### response ###

	- The response is available to the callback function as `this`.
	- The response is not passed into the callback.
	- `this.reponseText` will have the resulting data from the file.

	### example ###

		x$('#status').xhr('inner', '/status.html');
		x$('#status').xhr('outer', '/status.html');
		x$('#status').xhr('top',   '/status.html');
		x$('#status').xhr('bottom','/status.html');
		x$('#status').xhr('before','/status.html');
		x$('#status').xhr('after', '/status.html');

	or

		// same as using 'inner'
		x$('#status').xhr('/status.html');

		// define a callback, enable async execution and add a request header
		x$('#left-panel').xhr('/panel', {
		    async: true,
		    callback: function() {
		        alert("The response is " + this.responseText);
		    },
        headers:{
            'Mobile':'true'
        }
		});

		// define a callback with the shorthand syntax
		x$('#left-panel').xhr('/panel', function() {
		    alert("The response is " + this.responseText);
		});
*/
    xhr:function(location, url, options) {

      // this is to keep support for the old syntax (easy as that)
		if (!/^(inner|outer|top|bottom|before|after)$/.test(location)) {
            options = url;
            url = location;
            location = 'inner';
        }

        var o = options ? options : {};
        
        if (typeof options == "function") {
            // FIXME kill the console logging
            // console.log('we been passed a func ' + options);
            // console.log(this);
            o = {};
            o.callback = options;
        };
        
        var that   = this,
            req    = new XMLHttpRequest(),
            method = o.method || 'get',
            async  = (typeof o.async != 'undefined'?o.async:true),
            params = o.data || null,
            key;

        req.queryString = params;
        req.open(method, url, async);

        // Set "X-Requested-With" header
        req.setRequestHeader('X-Requested-With','XMLHttpRequest');

        if (method.toLowerCase() == 'post') req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');

        for (key in o.headers) {
            if (o.headers.hasOwnProperty(key)) {
              req.setRequestHeader(key, o.headers[key]);
            }
        }

        req.handleResp = (o.callback != null) ? o.callback : function() { that.html(location, req.responseText); };
        req.handleError = (o.error && typeof o.error == 'function') ? o.error : function () {};
        function hdl(){
            if(req.readyState==4) {
                delete(that.xmlHttpRequest);
                if(req.status===0 || req.status==200) req.handleResp(); 
                if((/^[45]/).test(req.status)) req.handleError();
            }
        }
        if(async) {
            req.onreadystatechange = hdl;
            this.xmlHttpRequest = req;
        }
        req.send(params);
        if(!async) hdl();

        return this;
    }
});
// emile.js (c) 2009 Thomas Fuchs
// Licensed under the terms of the MIT license.

(function(emile, container){
  var parseEl = document.createElement('div'),
    props = ('backgroundColor borderBottomColor borderBottomWidth borderLeftColor borderLeftWidth '+
    'borderRightColor borderRightWidth borderSpacing borderTopColor borderTopWidth bottom color fontSize '+
    'fontWeight height left letterSpacing lineHeight marginBottom marginLeft marginRight marginTop maxHeight '+
    'maxWidth minHeight minWidth opacity outlineColor outlineOffset outlineWidth paddingBottom paddingLeft '+
    'paddingRight paddingTop right textIndent top width wordSpacing zIndex').split(' ');

  function interpolate(source,target,pos){ return (source+(target-source)*pos).toFixed(3); }
  function s(str, p, c){ return str.substr(p,c||1); }
  function color(source,target,pos){
    var i = 2, j, c, tmp, v = [], r = [];
    while(j=3,c=arguments[i-1],i--)
      if(s(c,0)=='r') { c = c.match(/\d+/g); while(j--) v.push(~~c[j]); } else {
        if(c.length==4) c='#'+s(c,1)+s(c,1)+s(c,2)+s(c,2)+s(c,3)+s(c,3);
        while(j--) v.push(parseInt(s(c,1+j*2,2), 16)); }
    while(j--) { tmp = ~~(v[j+3]+(v[j]-v[j+3])*pos); r.push(tmp<0?0:tmp>255?255:tmp); }
    return 'rgb('+r.join(',')+')';
  }
  
  function parse(prop){
    var p = parseFloat(prop), q = prop.replace(/^[\-\d\.]+/,'');
    return isNaN(p) ? { v: q, f: color, u: ''} : { v: p, f: interpolate, u: q };
  }
  
  function normalize(style){
    var css, rules = {}, i = props.length, v;
    parseEl.innerHTML = '<div style="'+style+'"></div>';
    css = parseEl.childNodes[0].style;
    while(i--) if(v = css[props[i]]) rules[props[i]] = parse(v);
    return rules;
  }  
  
  container[emile] = function(el, style, opts, after){
    el = typeof el == 'string' ? document.getElementById(el) : el;
    opts = opts || {};
    var target = normalize(style), comp = el.currentStyle ? el.currentStyle : getComputedStyle(el, null),
      prop, current = {}, start = +new Date, dur = opts.duration||200, finish = start+dur, interval,
      easing = opts.easing || function(pos){ return (-Math.cos(pos*Math.PI)/2) + 0.5; };
    for(prop in target) current[prop] = parse(comp[prop]);
    interval = setInterval(function(){
      var time = +new Date, pos = time>finish ? 1 : (time-start)/dur;
      for(prop in target)
        el.style[prop] = target[prop].f(current[prop].v,target[prop].v,easing(pos)) + target[prop].u;
      if(time>finish) { clearInterval(interval); opts.after && opts.after(); after && setTimeout(after,1); }
    },10);
  }
})('emile', this);
!function (context, doc) {
  var fns = [], ol, fn, f = false,
      testEl = doc.documentElement,
      hack = testEl.doScroll,
      domContentLoaded = 'DOMContentLoaded',
      addEventListener = 'addEventListener',
      onreadystatechange = 'onreadystatechange',
      loaded = /^loade|c/.test(doc.readyState);

  function flush(i) {
    loaded = 1;
    while (i = fns.shift()) { i() }
  }
  doc[addEventListener] && doc[addEventListener](domContentLoaded, fn = function () {
    doc.removeEventListener(domContentLoaded, fn, f);
    flush();
  }, f);


  hack && doc.attachEvent(onreadystatechange, (ol = function () {
    if (/^c/.test(doc.readyState)) {
      doc.detachEvent(onreadystatechange, ol);
      flush();
    }
  }));

  context['domReady'] = hack ?
    function (fn) {
      self != top ?
        loaded ? fn() : fns.push(fn) :
        function () {
          try {
            testEl.doScroll('left');
          } catch (e) {
            return setTimeout(function() { context['domReady'](fn) }, 50);
          }
          fn();
        }()
    } :
    function (fn) {
      loaded ? fn() : fns.push(fn);
    };

}(this, document);
})();

return window.x$; };});

require.define("/.tmp.10403.entry.app.js",function(require,module,exports,__dirname,__filename,process){window.require = require;

// lazy require so that app code will not execute before onload
Object.defineProperty(window, 'main', {
  get: function() {
    return require('./app.js');
  }
});});
require("/.tmp.10403.entry.app.js");
})();
