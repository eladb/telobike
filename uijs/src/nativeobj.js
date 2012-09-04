var EventEmitter = require('uijs').events.EventEmitter;

window.uijs_native_objects = {}; // used to emit events from native code
window.uijs_emit_event = function(objid, event, args) {
  var obj = window.uijs_native_objects[objid];
  if (!obj) {
    console.warn('unable to emit event ' + event + ' from native object with id ' + objid + ' because object not found');
    return; // object not found
  }

  return obj.emit(event, args);
};

window.uijs_hittest = function(options) {
  
  if (!options) {
    console.log('uijs_hittest: no options');
    return false;
  }

  var canvas = window.uijs_canvas;
  if (!canvas) {
    console.log('uijs_hittest: no canvas');
    return false;
  }

  var pt = options.pt;
  if (!pt) {
    console.log('uijs_hittest: no options.pt');
    return false;
  }

  // console.log('uijs_hittest pt=(' + pt.x + ',' + pt.y + ')');
  var ht = canvas.hittest(pt);

  // check if that last hitted box is a native object.
  var obj_ids = Object.keys(ht);
  var last_objid = obj_ids[obj_ids.length - 1];
  var last_box = ht[last_objid].child;

  if (last_box._id in window.uijs_native_objects) {
    // console.log(last_box._id + ' is a native object');
    return false;
  }

  return true;
};

module.exports = function(type, id, options) {
  var obj = new EventEmitter();

  var cordova = window.cordova || window.Cordova;
  if (!cordova) {
    console.warn('No phonegap environment. Unable to create native object of type ' + type);
    obj.mock = true;
    obj.call = function(method, args, callback) {
      callback = callback || function() {};
      console.log('uijs_native:', method, args);
      try {
        var s = JSON.stringify(args);
        return callback();
      }
      catch (e) {
        console.error('Cannot serialize arguments: ' + e);
        return callback(e);
      }
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

    try {
      var sargs = JSON.stringify(args);
      // console.log('native invoke ' + type + '[' + id + '].' + method);
      return cordova.exec(success, failure, 'org.uijs.native', 'invoke', [ method, type, id, sargs ]);
    }
    catch(e) {
      console.error('Unable to serialize args: ' + e);
      return callback(e);
    }
  };

  obj.call('init', options, function(err) {
    if (!err) {
      alert('init error: ' + err.toString());
    }
  });

  return obj;
};