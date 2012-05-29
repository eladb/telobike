var path = require('path');
var fs = require('fs');
var mkdirp = require('mkdirp');

function cache(name, options) {
  name = name || '_global';

  var cache = {};
  var cache_dir = path.join('/tmp', 'obj_cache', name);
  var api = {};

  options = options || {};
  var ttl = options.ttl || 60 * 1000;

  api.set = function(key, obj) {
    // save in-memory
    cache[key] = {
      mtime: new Date(),
      obj: obj,
    };

    // save persistent
    return mkdirp(cache_dir, function(err) {
      if (err) {
        console.warn('unable to create directory %s for persistent cache: %s', cache_dir, err);
        return;
      }

      var cache_file = _get_cache_filename(key);
      fs.writeFile(cache_file, JSON.stringify(obj), function(err) {
        if (err) console.warn('unable to store cache entry for %s in %s: %s', key, cache_file, err);
      });
    });
  };

  api.get = function(key, callback) {
    // first, check in-memory cache
    var mem_cache_entry = cache[key];
    var mem_cached = mem_cache_entry && (ttl === -1 || ((new Date() - mem_cache_entry.mtime) < ttl));
    if (mem_cached) return callback(mem_cache_entry.obj);

    // now, try to retrieve from persistent cache
    var cache_file = _get_cache_filename(key);
    return fs.stat(cache_file, function(err, stat) {
      if (err) return callback(null);


      var fs_cached = !err && (ttl === -1 || ((new Date() - stat.mtime) < ttl));
      if (!fs_cached) return callback(null);

      // cache file is up-to-date, try to read it
      return fs.readFile(cache_file, function(err, data) {
        if (err) return callback(null);
        
        var obj;
        try { obj = JSON.parse(data); }
        catch (e) { return callback(null); }

        return callback(obj);
      });
    });
  }

  function _get_cache_filename(key) {
    return path.join(cache_dir, key + '.cache');
  }

  return api;
};

module.exports = cache;