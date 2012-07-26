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

require.define("/phonegap/src/station-panel.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
var box = uijs.box;
var demostack = require('../../uijs/samples/lib/demostack');
var defaults = uijs.util.defaults;
var nativeobj = require('./nativeobj');
var animate = uijs.animation;
var positioning = uijs.positioning;
var image = require('uijs-controls').image;
var loadimage = uijs.util.loadimage;

module.exports = function(options) {

  function statusbox(options) {
    var obj = box(defaults(options, {
      background: 'red',
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

  obj.ondraw = function(ctx) {
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, this.width, this.height);
  };

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
      return obj.station.name;
    }
  }));

  var bike_status = bg.add(statusbox({ 
    id: '#bicycle',
    icon: loadimage('assets/img/icon_bike.png'),
    x: 15, y: positioning.relative('#name').bottom(-4),
    count: function() {
      return obj.station.available_bike;
    },
  }));

  var park_status = bg.add(statusbox({ 
    id: '#parking',
    icon: loadimage('assets/img/icon_parking.png'),
    x: positioning.prev.right(), y: positioning.prev.top(),
    count: function() {
      return obj.station.available_spaces;
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
    console.log('report');
  });

  fav_button.on('click', function() {
    console.log('fav');
  });

  nav_button.on('click', function() {
    console.log('nav');
  });

  return obj;
};

function button(options) {

  var obj = image(defaults(options, {
    image: loadimage('assets/img/button.png'),
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
    this._touching = true;
    this.startCapture();
  });

  obj.on('touchend', function(e) {
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
}

function label(options) {
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
}
});

require.define("/phonegap/src/node_modules/uijs/package.json",function(require,module,exports,__dirname,__filename,process){module.exports = {"main":"./lib/index"}});

require.define("/phonegap/src/node_modules/uijs/lib/index.js",function(require,module,exports,__dirname,__filename,process){exports.canvasize = require('./canvasize');
exports.box = require('./box');
exports.html = require('./html');
exports.util = require('./util');
exports.positioning = require('./positioning');
exports.interaction = require('./interaction');
exports.animation = require('./animation');
exports.events = require('./events');});

require.define("/phonegap/src/node_modules/uijs/lib/canvasize.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
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

require.define("/phonegap/src/node_modules/uijs/lib/box.js",function(require,module,exports,__dirname,__filename,process){var defaults = require('./util').defaults;
var valueof = require('./util').valueof;
var propertize = require('./util').propertize;
var EventEmitter = require('./events').EventEmitter;

var idgenerator = 0;

var box = module.exports = function(options) {

  var attributes = defaults(options, {
    x: 0,
    y: 0,
    width: 100,
    height: 100,
    rotation: 0.0,
    visible: true,
    clip: false,
    alpha: null,
    debug: false,
    interaction: true, // send interaction events on this box. must be set to true for events to be emitted
    autopropagate: true, // propagate interaction events to child boxes. if false, the parent needs to call `e.propagate()` on the event
    id: function() { return this._id; },
  });

  var obj = new EventEmitter();

  for (var k in attributes) {
    obj[k] = attributes[k];
  }

  // turn all attributes except `onxxx` and anything that begins with a '_' to properties.
  propertize(obj, function(attr) {
    return !(attr.indexOf('on') === 0 || attr.indexOf('_') === 0);
  });

  obj._id = 'BOX.' + idgenerator++;
  obj._is_box  = true;
  obj._children = {};

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

    self._children[child._id] = child;

    self.queue('child', child);

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
    var children = self.parent._children;
    var previd = null;

    for (var sibling_id in children) {
      if (sibling_id === self._id.toString()) {
        
        if (!previd) return null; // first child.
        return children[previd];
      }

      previd = sibling_id;
    }

    return null;
  };

  // removes a child (or self from parent)
  obj.remove = function(child) {
    var self = this;

    if (!child) {
      if (!self.parent) throw new Error('`remove()` will only work if you have a parent');
      self.parent.remove(self);
      return child;
    }

    delete self._children[child._id];
    child.parent = null;
    return child;
  };

  // removes all children
  obj.empty = function() {
    var self = this;
    for (var k in self._children) {
      self.remove(self._children[k]);
    }
    return self;
  };

  // retrieve a child by it's `id()` property (or _id). children without
  // this property cannot be retrieved using this function.
  obj.get = function(id) {
    var self = this;
    for (var k in self._children) {
      var child = self._children[k];
      if (child.id === id) {
        return child;
      }
    }

    return null;
  };

  // ### box.query(id)
  // Retrieves a child from the entire box tree by id.
  obj.query = function(id) {
    var self = this;
    var child = self.get(id);
    if (!child) {
      for (var k in self._children) {
        var found = self._children[k].query(id);
        if (found) {
          child = found;
          break;
        }
      }
    }
    return child;
  };

  /// ### box.all()
  /// Returns all the children of this box.
  obj.all = function() {
    var self = this;
    return Object.keys(self._children)
      .map(function(k) { return self._children[k]; });
  };

  /// ### box.rest([child])
  /// Returns all the children that are not `child` (or do the same on the parent if `child` is null)
  obj.rest = function(child) {
    var self = this;
    if (!child) {
      if (!obj.parent) throw new Error('cannot call `rest()` without a parent');
      return obj.parent.rest(self);
    }
    return Object.keys(self._children)
      .filter(function(k) { return k != child._id; })
      .map(function(k) { return self._children[k]; });
  };


  // returns the first child
  obj.first = function() {
    var self = this;
    var keys = self._children && Object.keys(self._children);
    if (!keys || keys.length === 0) return null;
    return self._children[keys[0]];
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
    
    box.all().forEach(function(child) {
      s += child.tree(indent + 2);
    });

    return s;
  }

  // if `children` is defined in construction, add them and
  // replace with a property so we can treat children as an array
  if (obj.children) {
    obj.add(obj.children);
    delete obj.children;
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

    Object.keys(self._children).forEach(function(key) {
      //TODO: do not draw child if out of viewport
      var child = self._children[key];
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
    var ids = Object.keys(self._children).reverse();

    for (var i = 0; i < ids.length; ++i) {
      var child = self._children[ids[i]];

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

    // queue the event locally to this box
    if (self.debug) console.log('[' + self.id + ']', event, pt);
    self.emit(event, pt);

    // nothing to do if `propagate` is false.
    if (!self.autopropagate) return;

    return self.propagate(event, pt);
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
    delete captures[this._id];
  };

  return obj;
};

box.isbox = function(obj) {
  return obj._is_box || obj._is_view;
};});

require.define("/phonegap/src/node_modules/uijs/lib/util.js",function(require,module,exports,__dirname,__filename,process){exports.min = function(a, b) { return a < b ? a : b; };
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

  function prop(obj, name) {
    var prev = obj[name];

    var curr = null;
    Object.defineProperty(obj, name, {
      get: function() {
        if (typeof curr === 'function') return curr.call(this);
        else return curr;
      },
      set: function(value) {
        curr = value;
      }
    });

    obj[name] = prev;

    obj.properties = obj.properties || [];
    obj.properties.push(name); // manage a list of property names
  }

  for (var attr in obj) {
    if (!obj.hasOwnProperty(attr)) continue; // skip properties from linked objects
    if (!filter(attr)) continue;
    prop(obj, attr);
  }

  return obj;
};
});

require.define("/phonegap/src/node_modules/uijs/lib/events.js",function(require,module,exports,__dirname,__filename,process){function EventEmitter() {
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

require.define("/phonegap/src/node_modules/uijs/lib/interaction.js",function(require,module,exports,__dirname,__filename,process){// maps DOM events to uijs event names
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

require.define("/phonegap/src/node_modules/uijs/lib/html.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
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

require.define("/phonegap/src/node_modules/uijs/lib/positioning.js",function(require,module,exports,__dirname,__filename,process){//
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

require.define("/phonegap/src/node_modules/uijs/lib/animation.js",function(require,module,exports,__dirname,__filename,process){// -- animation
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
  options.callback = options.callback || function() { };
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
      if (options.callback && !callbackCalled) {
        options.callback.call(this);
        callbackCalled = true;
      }
    }
    return curr;
  };
};});

require.define("/uijs/samples/lib/demostack.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
var positioning = uijs.positioning;
var defaults = uijs.util.defaults;
var box = uijs.box;
var override = uijs.util.override;
var html = uijs.html;
var animate = uijs.animation;

function label(options) {
  options = defaults(options, {
    title: false,
    lineHeight: 1,
    height: 30,
    backgroundColor: '#0191C8',
    width: positioning.parent.width(),
  });
  var obj = box(options);
  obj._is_adornment = true;
  obj.ondraw = function(ctx) {

    var lineHeight = this.lineHeight;

    ctx.fillStyle = this.backgroundColor;
    ctx.shadowBlur = 10;
    ctx.shadowColor = 'black';
    ctx.fillRect(0, 0, this.width, this.height);

    ctx.shadowBlur = 0;

    ctx.font = '16px Helvetica';
    ctx.fillStyle = 'black';

    if (this.title) {
      ctx.fillText(this.title, 10, 20 + lineHeight);
    }
  };
  return obj;
}

module.exports = function(options) {
  options = defaults(options, {
    backgroundColor: '#005B9A',
  });
  
  var obj = box(options);
  obj.x = 0;
  obj.y = 0;
  obj.width = positioning.parent.width();
  obj.height = positioning.parent.height();

  var content = obj.add(box({
    x: 0,
    y: 0,
    width: positioning.parent.width(),
    height: positioning.parent.height(),
  }));

  var options_box = obj.add(html({
    x: positioning.parent.centerx(),
    y: positioning.parent.centery(),
    width: 0,
    height: 0,
  }));

  options_box.ondraw = function(ctx) {
    ctx.fillStyle = 'white';
    ctx.shadowBlur = 20;
    ctx.shadowColor = 'black';
    ctx.fillRect(0, 0, this.width, this.height);
  };

  options_box.onload = function(c) {
    c.style.padding = 10;
  };

  obj.closeOptions = function() {
    var currw = options_box.width;
    var currh = options_box.height;
    options_box.width = animate(currw, 0);
    options_box.height = animate(currh, 0);
  };

  content.ondraw = function(ctx) {
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, this.width, this.height);
  };

  obj.add = function(child) {

    var children = content.all();
    var last = children[children.length - 1];
    if (last) last.remove();

    var titlebar = content.add(label({
      y: positioning.prev.bottom(),
      title: child.title || 'child has no `title` attribute',
    }));

    var options_button = titlebar.add(html({
      html: '<button>Options</button>',
      x: positioning.parent.right(-65),
      y: 4,
      width: 60,
      height: 22,
    }));

    options_button.onload = function(container) {
      var button = container.firstChild;
      button.style.width = '100%';
      button.style.height = '100%';
      button.onclick = function() {
        if (!child.onoptions) {
          alert('No options for this demo. Define `onoptions(box)` and set `box.innerHTML`');
          return;
        }

        options_box.width = animate(0, options_box.parent.width * 0.5);
        options_box.height = animate(0, options_box.parent.height * 0.8);
        child.onoptions(options_box.container);
      };
    };

    child.width = positioning.parent.width();
    child.y = positioning.prev.bottom();
    var ret = content.add(child);

    content.add(label({
      y: positioning.prev.bottom(),
      height: function() { return content.parent.height - content.y; },
    }));

    return child;
  };

  obj.ondraw = function(ctx) {
    ctx.fillStyle = this.backgroundColor;
    ctx.fillRect(0, 0, this.width, this.height);
  };

  return obj;
};});

require.define("/uijs/samples/node_modules/uijs/package.json",function(require,module,exports,__dirname,__filename,process){module.exports = {"main":"./lib/index"}});

require.define("/uijs/samples/node_modules/uijs/lib/index.js",function(require,module,exports,__dirname,__filename,process){exports.canvasize = require('./canvasize');
exports.box = require('./box');
exports.html = require('./html');
exports.util = require('./util');
exports.positioning = require('./positioning');
exports.interaction = require('./interaction');
exports.animation = require('./animation');
exports.events = require('./events');});

require.define("/uijs/samples/node_modules/uijs/lib/canvasize.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
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

require.define("/uijs/samples/node_modules/uijs/lib/box.js",function(require,module,exports,__dirname,__filename,process){var defaults = require('./util').defaults;
var valueof = require('./util').valueof;
var propertize = require('./util').propertize;
var EventEmitter = require('./events').EventEmitter;

var idgenerator = 0;

var box = module.exports = function(options) {

  var attributes = defaults(options, {
    x: 0,
    y: 0,
    width: 100,
    height: 100,
    rotation: 0.0,
    visible: true,
    clip: false,
    alpha: null,
    debug: false,
    interaction: true, // send interaction events on this box. must be set to true for events to be emitted
    autopropagate: true, // propagate interaction events to child boxes. if false, the parent needs to call `e.propagate()` on the event
    id: function() { return this._id; },
  });

  var obj = new EventEmitter();

  for (var k in attributes) {
    obj[k] = attributes[k];
  }

  // turn all attributes except `onxxx` and anything that begins with a '_' to properties.
  propertize(obj, function(attr) {
    return !(attr.indexOf('on') === 0 || attr.indexOf('_') === 0);
  });

  obj._id = 'BOX.' + idgenerator++;
  obj._is_box  = true;
  obj._children = {};

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

    self._children[child._id] = child;

    self.queue('child', child);

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
    var children = self.parent._children;
    var previd = null;

    for (var sibling_id in children) {
      if (sibling_id === self._id.toString()) {
        
        if (!previd) return null; // first child.
        return children[previd];
      }

      previd = sibling_id;
    }

    return null;
  };

  // removes a child (or self from parent)
  obj.remove = function(child) {
    var self = this;

    if (!child) {
      if (!self.parent) throw new Error('`remove()` will only work if you have a parent');
      self.parent.remove(self);
      return child;
    }

    delete self._children[child._id];
    child.parent = null;
    return child;
  };

  // removes all children
  obj.empty = function() {
    var self = this;
    for (var k in self._children) {
      self.remove(self._children[k]);
    }
    return self;
  };

  // retrieve a child by it's `id()` property (or _id). children without
  // this property cannot be retrieved using this function.
  obj.get = function(id) {
    var self = this;
    for (var k in self._children) {
      var child = self._children[k];
      if (child.id === id) {
        return child;
      }
    }

    return null;
  };

  // ### box.query(id)
  // Retrieves a child from the entire box tree by id.
  obj.query = function(id) {
    var self = this;
    var child = self.get(id);
    if (!child) {
      for (var k in self._children) {
        var found = self._children[k].query(id);
        if (found) {
          child = found;
          break;
        }
      }
    }
    return child;
  };

  /// ### box.all()
  /// Returns all the children of this box.
  obj.all = function() {
    var self = this;
    return Object.keys(self._children)
      .map(function(k) { return self._children[k]; });
  };

  /// ### box.rest([child])
  /// Returns all the children that are not `child` (or do the same on the parent if `child` is null)
  obj.rest = function(child) {
    var self = this;
    if (!child) {
      if (!obj.parent) throw new Error('cannot call `rest()` without a parent');
      return obj.parent.rest(self);
    }
    return Object.keys(self._children)
      .filter(function(k) { return k != child._id; })
      .map(function(k) { return self._children[k]; });
  };


  // returns the first child
  obj.first = function() {
    var self = this;
    var keys = self._children && Object.keys(self._children);
    if (!keys || keys.length === 0) return null;
    return self._children[keys[0]];
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
    
    box.all().forEach(function(child) {
      s += child.tree(indent + 2);
    });

    return s;
  }

  // if `children` is defined in construction, add them and
  // replace with a property so we can treat children as an array
  if (obj.children) {
    obj.add(obj.children);
    delete obj.children;
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

    Object.keys(self._children).forEach(function(key) {
      //TODO: do not draw child if out of viewport
      var child = self._children[key];
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
    var ids = Object.keys(self._children).reverse();

    for (var i = 0; i < ids.length; ++i) {
      var child = self._children[ids[i]];

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

    // queue the event locally to this box
    if (self.debug) console.log('[' + self.id + ']', event, pt);
    self.emit(event, pt);

    // nothing to do if `propagate` is false.
    if (!self.autopropagate) return;

    return self.propagate(event, pt);
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
    delete captures[this._id];
  };

  return obj;
};

box.isbox = function(obj) {
  return obj._is_box || obj._is_view;
};});

require.define("/uijs/samples/node_modules/uijs/lib/util.js",function(require,module,exports,__dirname,__filename,process){exports.min = function(a, b) { return a < b ? a : b; };
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

  function prop(obj, name) {
    var prev = obj[name];

    var curr = null;
    Object.defineProperty(obj, name, {
      get: function() {
        if (typeof curr === 'function') return curr.call(this);
        else return curr;
      },
      set: function(value) {
        curr = value;
      }
    });

    obj[name] = prev;

    obj.properties = obj.properties || [];
    obj.properties.push(name); // manage a list of property names
  }

  for (var attr in obj) {
    if (!obj.hasOwnProperty(attr)) continue; // skip properties from linked objects
    if (!filter(attr)) continue;
    prop(obj, attr);
  }

  return obj;
};
});

require.define("/uijs/samples/node_modules/uijs/lib/events.js",function(require,module,exports,__dirname,__filename,process){function EventEmitter() {
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

require.define("/uijs/samples/node_modules/uijs/lib/interaction.js",function(require,module,exports,__dirname,__filename,process){// maps DOM events to uijs event names
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

require.define("/uijs/samples/node_modules/uijs/lib/html.js",function(require,module,exports,__dirname,__filename,process){var box = require('./box');
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

require.define("/uijs/samples/node_modules/uijs/lib/positioning.js",function(require,module,exports,__dirname,__filename,process){//
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

require.define("/uijs/samples/node_modules/uijs/lib/animation.js",function(require,module,exports,__dirname,__filename,process){// -- animation
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
  options.callback = options.callback || function() { };
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
      if (options.callback && !callbackCalled) {
        options.callback.call(this);
        callbackCalled = true;
      }
    }
    return curr;
  };
};});

require.define("/phonegap/src/nativeobj.js",function(require,module,exports,__dirname,__filename,process){var EventEmitter = require('uijs').events.EventEmitter;

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
    console.error('No phonegap environment. Unable to create native object of type ' + type);
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

require.define("/phonegap/src/node_modules/uijs-controls/package.json",function(require,module,exports,__dirname,__filename,process){module.exports = {"main":"lib/index"}});

require.define("/phonegap/src/node_modules/uijs-controls/lib/index.js",function(require,module,exports,__dirname,__filename,process){exports.image = require('./image');
exports.listView = require('./listView');});

require.define("/phonegap/src/node_modules/uijs-controls/lib/image.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
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

require.define("/phonegap/src/node_modules/uijs-controls/lib/listView.js",function(require,module,exports,__dirname,__filename,process){var uijs = require('uijs');
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

require.define("/phonegap/src/.tmp.26163.entry.station-panel.js",function(require,module,exports,__dirname,__filename,process){window.require = require;

// lazy require so that app code will not execute before onload
Object.defineProperty(window, 'main', {
  get: function() {
    return require('./station-panel.js');
  }
});});
require("/phonegap/src/.tmp.26163.entry.station-panel.js");
})();
