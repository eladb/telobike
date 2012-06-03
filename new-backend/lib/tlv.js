var fs = require('fs');
var path = require('path');
var jqget = require('./jqget');
var async = require('async');
var cache = require('./cache');

module.exports = function() {
  var base_url = 'http://www.tel-o-fun.co.il/'
  var api = {};

  var list_cache = cache('list-cache', { ttl: -1 });
  var station_cache = cache('station-cache', { ttl: -1 });

  /**
   * Refreshes the station list (name, sid and location)
   */
  function refresh_list(use_cache, callback) {
    return list_cache.get('.', function(cached_stations) {
      if (use_cache && cached_stations) return callback(null, cached_stations);

      var url = base_url + encodeURI('תחנותתלאופן.aspx');
      console.log('GET %s', url);
      return jqget(url, function(err, $) {
        if (err) return callback(err);

        var stations = {};

        $('a.bicycle_station').each(function() {
          var name = $(this).text();
          var sid = $(this).attr('sid');
          var lng = $(this).attr('x');
          var lat = $(this).attr('y');

          // update stations hash
          var station = sid in stations ? stations[sid] : {};
          station.name = name;
          station.sid = sid;
          station.id = sid;
          station.latitude = lat;
          station.longitude = lng;
          station.location = lat + ',' + lng;
          station.city = 'tlv';
          stations[sid] = station;
        });

        list_cache.set('.', stations);

        return callback(null, stations);
      });
    });
  };

  function refresh_station(use_cache, id, callback) {
    return station_cache.get(id, function(cached_station) {
      if (use_cache && cached_station) return callback(null, cached_station);

      return refresh_list(use_cache, function(err, stations) {
        var station = stations[id];
        if (!station) return callback(new Error('station ' + id + ' not found'));

        var url = base_url + 'DesktopModules/Locations/StationData.ashx?en=1&sid=' + id;
        console.log('GET %s', url);

        return jqget(url, function(err, $) {
          if (err) return callback(err);
          var name_en = $('div div:eq(1)').text();
          station.name_en = name_en;
          var stats = $('div div:eq(3)').html();
          var parser = /<br \/>Avalable bicycles \: (\d+)<br \/>Avalable poles\: (\d+)/;
          var _ = parser.exec(stats);
          station.available_bike = _[1];
          station.available_spaces = _[2];
          station.last_update_time = new Date();
          station.last_update = station.last_update_time.toISOString().replace('Z', '').replace('T', ' ');

          console.log('STORE %s', id);
          station_cache.set(id, station);
          return callback(null, station);
        });
      });
    });
  }

  function refresh_all(use_cache, callback) {
    var result = {};
    return refresh_list(use_cache, function(err, stations) {
      if (err) return callback(err);      
      return async.forEach(Object.keys(stations), function(id, cb) {
        return refresh_station(use_cache, id, function(err, station) {
          if (err) return cb();
          if (station) result[id] = station;
          return cb();
        });
      }, function() {
        return callback(null, result);
      });
    });
  }

  /**
   * Returns at least the station list (and if there is any cached data, it will also be returned)
   */
  api.list = function(callback) {
    return refresh_list(true, callback);
  };

  api.one = function(id, callback) {
    return refresh_station(true, id, callback);
  };

  /** 
   * Returns all the stations and their details
   */
  api.all = function(callback) {
    return refresh_all(true, callback);
  };

  /**
   * Trigger a refresh
   */
  api.refresh = function() {
    return refresh_all(false, function() { });
  };

  return api;
};