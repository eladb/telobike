import logging
import tlv
import paris
from stations_endpoint import Station
from google.appengine.api import taskqueue

def deferred_read_stations(city):
    logging.info('reading stations for city %s' % city)
    if city == 'tlv': stations = tlv.read_stations()
    if city == 'paris': stations = paris.read_stations()
    
    # now, go over all the stations and update the storage, then do a refresh
    for station in stations:
        logging.info('storing station: %s' % station)
        stored_station = Station.get_or_insert(station['sid'])
        stored_station.name = station['name']
        stored_station.location = '%s,%s' % (station['latitude'], station['longitude'])
        if 'available_bike' in station: stored_station.available_bike = int(station['available_bike'])
        if 'available_spaces' in station: stored_station.available_spaces = int(station['available_spaces'])
        if 'address' in station: stored_station.address = station['address']
        stored_station.city = city
        stored_station.put()
        taskqueue.add(url = '/stations/refresh-station', params = { 'city': city, 'sid': station['sid']})