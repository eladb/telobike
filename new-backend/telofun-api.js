var soap = require('soap');
var location = 'http://www.tel-o-fun.co.il:2470/ExternalWS/Geo.asmx?wsdl';

module.exports = function(callback) {
  return soap.createClient(location, function(err, client) {
    if (err) return callback(err);
    if (!client.GetNearestStations) return callback(new Error('could not find GetNearestStations'));

    var params = {
      longitude: 32.066246,
      langitude: 34.77754,
      radius: 1000000,
      maxResults: 10000,
    };

    return client.GetNearestStations(params, function(err, results, body) {
      if (err) return callback(err);
      return callback(null, 
        results &&
        results.GetNearestStationsResult && 
        results.GetNearestStationsResult.length > 0 &&
        results.GetNearestStationsResult[0].StationsCloseBy &&
        results.GetNearestStationsResult[0].StationsCloseBy.Station);
    });
  });
};