from google.appengine.ext import db

class Station(db.Model):
    """Represents a stations
    The key().name() is the station ID in the tel-o-fun system.
    """
    last_update = db.DateTimeProperty(auto_now=True, required=True)
    name = db.StringProperty()
    location = db.GeoPtProperty()
    available_bike = db.IntegerProperty()
    available_spaces = db.IntegerProperty()
    city = db.StringProperty()
    address = db.StringProperty()
    tags = db.StringListProperty()
    name_en = db.StringProperty()
    is_broken = db.BooleanProperty()
    is_broken_since= db.DateTimeProperty()

class StationHistory(Station):
    sid = db.StringProperty() # we need sid here since in the in the Station model this is the key name and here we save all the history
   
    @classmethod
    def append(cls, stored_station):
        # create a copy of the current state of the station and append it to the history table
        station_history_entry = StationHistory()
        station_history_entry.sid = stored_station.key().name()
        props = stored_station.properties()
        for prop in props:
            setattr(station_history_entry, prop, getattr(stored_station, prop))
        station_history_entry.put()

class City(db.Model):
    """Information about the rental service
    Key name is the city.
    """
    last_update = db.DateTimeProperty(auto_now=True, required=True)
    service_name = db.StringProperty()
    service_name_en = db.StringProperty()
    city_name = db.StringProperty()
    city_name_en = db.StringProperty()
    mail = db.EmailProperty()
    mail_tags = db.StringProperty()
    city_center = db.GeoPtProperty()
    disclaimer = db.StringProperty()
    info_url_he = db.LinkProperty()
    info_url = db.LinkProperty()
    
    @classmethod
    def populate(cls):
        existing = City.get_by_key_name('tlv')
        if not existing:
            tlv = City.get_or_insert(key_name = 'tlv')
            tlv.service_name = 'Tel-o-Fun'
            tlv.service_name_en = 'Tel-o-Fun'
            tlv.city_name = 'Tel-Aviv'
            tlv.city_name_en = 'Tel-Aviv'
            tlv.mail = 'info@fsm-tlv.co.il'
            tlv.mail_tags = '#malfunction'
            tlv.info_url = 'http://telobike.citylifeapps.com/static/en/tlv.html'
            tlv.info_url_he = 'http://telobike.citylifeapps.com/static/he/tlv.html'
            tlv.put()
            
        if not existing.info_url_he:
            existing.info_url_he = 'http://telobike.citylifeapps.com/static/he/tlv.html'
            existing.put()
