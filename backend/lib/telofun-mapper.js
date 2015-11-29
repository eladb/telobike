//
// Tel-o-fun API:
//
// { 
//   Station_id: '101',
//   Station_Name: 'חוף הצוק הצפוני מלון מנדרין',
//   Eng_Station_Name: 'North Cliff Beach',
//   Description: 'חוף הצוק הצפוני מלון מנדרין',
//   Eng_Address: 'North Cliff Beach',
//   Latitude: '32.143800',
//   Longitude: '34.792600',
//   DistanceFromStationInMeters: '8722',
//   Timestamp: '2012-11-14T13:20:26.790',
//   NumOfAvailableBikes: '3',
//   NumOfAvailableDocks: '17',
//   IsActive: '1',
//   Station_picture: '',
//   Station_Phone: '*6070',
//   Telefax: '' 
// }
//
//
// Telobike API:
//
// {
//   available_bike: "3",
//   available_spaces: "17",
//   city: "tlv",
//   last_update: "2012-11-14 11:17:45.378",
//   latitude: 32.1438,
//   location: "32.1438,34.7926",
//   longitude: 34.7926,
//   name: "חוף הצוק הצפוני",
//   sid: "101",
//   address: "חוף הצוק הצפוני מלון מנדרין",
//   name_en: "North Cliff Beach",
//   address_en: "North Cliff Beach"
// }
//

module.exports = function(attributes) {
  var station = attributes.attributes;
  return {
    IsActive: station.IsActive,
    available_bike: station.IsActive && station.NumOfAvailableBikes,
    available_spaces: station.IsActive && station.NumOfAvailableDocks,
    city: 'tlv',
    last_update: (new Date().toJSON()).replace(/[\"Z]/g, '').replace(/T/g, ' '),
    latitude: station.Latitude,
    location: station.Latitude + ',' + station.Longitude,
    longitude: station.Longitude,
    name: station.Station_Name,
    sid: station.Station_id,
    address: station.Description,
    name_en: station.Eng_Station_Name,
    address_en: station.Eng_Address,
  };
};