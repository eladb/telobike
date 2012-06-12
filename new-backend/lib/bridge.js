var jqget = require('./jqget');
var path = require('path');
var vm = require('vm');

function scrape(callback) {
  // var f = 'file://' + path.join(__dirname, 'out.html');
  var url = 'http://www.tel-o-fun.co.il/Default.aspx?TabID=64';

  return jqget(url, function(err, $) {
    if (err) return callback(err);

    var script = $('script');
    script.each(function(i, s) {
      var src = s.innerHTML;
      if (src.indexOf('function loadMarkers()') !== -1) {
        var sandbox = {};
        var now = JSON.stringify(new Date()).replace('T', ' ').replace('Z', '').replace(/\"/g, '');

        sandbox.stations = [];
        sandbox.setMarker = function(lng, lat, sid, name, address, total, slots) {
          sandbox.stations.push({
            available_bike: parseInt(total - slots).toString(),
            available_spaces: parseInt(slots).toString(),
            city: "tlv",
            last_update: now,
            latitude: lat,
            location: lat + "," + lng,
            longitude: lng,
            name: name,
            name_en: name,
            sid: sid.toString(),
            address: address || name,
          });
        };

        src += 'loadMarkers();';
        vm.runInNewContext(src, sandbox);

        return callback(null, sandbox.stations);
      }
    });
  });
}

module.exports = scrape;