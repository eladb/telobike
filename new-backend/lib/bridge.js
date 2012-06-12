var jqget = require('./jqget');
var path = require('path');
var vm = require('vm');

function scrape(lang, callback) {
  // var f = 'file://' + path.join(__dirname, 'out.html');
  //var url = ;
  var url = lang === 'he' 
    ? 'http://www.tel-o-fun.co.il/Default.aspx?TabID=64' 
    : 'http://www.tel-o-fun.co.il/en/TelOFunLocations.aspx';

  return jqget(url, function(err, $) {
    if (err) return callback(err);

    $('script').each(function(i, s) {
      var src = s.innerHTML;
      if (src.indexOf('function loadMarkers()') !== -1) {
        var sandbox = {};
        var now = JSON.stringify(new Date()).replace('T', ' ').replace('Z', '').replace(/\"/g, '');

        sandbox.stations = {};
        sandbox.setMarker = function(lng, lat, sid, name, address, total, slots) {
          sandbox.stations[sid] = {
            available_bike: parseInt(total - slots).toString(),
            available_spaces: parseInt(slots).toString(),
            city: "tlv",
            last_update: now,
            latitude: lat,
            location: lat + "," + lng,
            longitude: lng,
            name: name,
            sid: sid.toString(),
            address: address || name,
          };
        };

        src += 'loadMarkers();';
        vm.runInNewContext(src, sandbox);

        return callback(null, sandbox.stations);
      }
    });
  });
}

module.exports = scrape;