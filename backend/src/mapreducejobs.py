import logging
from model import StationHistory
from google.appengine.ext import db
from datetime import datetime
from mapreduce import operation as op

class AverageBikesPerHour(db.Model):
    hour = db.DateTimeProperty()
    sid = db.StringProperty()
    station_name = db.StringProperty()
    average_bikes = db.FloatProperty()
    average_slots = db.FloatProperty()
    samples = db.IntegerProperty()
    total_bikes = db.FloatProperty()
    total_slots = db.FloatProperty()
        
def average_bikes_per_hour(entity):

    def accumulate_averages(entity):
        hour = datetime(year = entity.last_update.year, month = entity.last_update.month, day = entity.last_update.day, hour = entity.last_update.hour, minute = 0, second = 0)
        key = "%s_%s" % (entity.sid, hour.strftime("%Y%m%d%H"))
        r = AverageBikesPerHour.get_by_key_name(key)
        if not r: r = AverageBikesPerHour(key_name = key)
        if not r.samples: r.samples = 0
        if not r.total_bikes: r.total_bikes = 0.0
        if not r.total_slots: r.total_slots = 0.0
        r.sid = entity.sid
        r.hour = hour
        r.station_name = entity.name
        r.samples = r.samples + 1 
        r.total_bikes = r.total_bikes + entity.available_bike 
        r.total_slots = r.total_slots + entity.available_spaces
        r.average_bikes = r.total_bikes / r.samples
        r.average_slots = r.total_slots / r.samples
        r.put()

    db.run_in_transaction(accumulate_averages, entity)    


class AverageBikesHourOfDay(db.Model):
    hour = db.IntegerProperty()
    day_of_week = db.IntegerProperty()
    sid = db.StringProperty()
    station_name = db.StringProperty()
    average_bikes = db.FloatProperty()
    average_slots = db.FloatProperty()
    samples = db.IntegerProperty()
    total_bikes = db.FloatProperty()
    total_slots = db.FloatProperty()

def average_bikes_per_hour_of_day(entity):
    hour = entity.last_update.hour
    day_of_week = (entity.last_update.weekday() + 1) % 7 # because monday is 0
    key = "%s_%d_%d" % (entity.sid, day_of_week, hour)

    def accumulate_averages(hour, day_of_week, key, entity):
        r = AverageBikesHourOfDay.get_by_key_name(key)
        if not r: r = AverageBikesHourOfDay(key_name = key)
        if not r.samples: r.samples = 0
        if not r.total_bikes: r.total_bikes = 0.0
        if not r.total_slots: r.total_slots = 0.0
        r.sid = entity.sid
        r.hour = hour
        r.day_of_week = day_of_week
        r.station_name = entity.name
        r.samples = r.samples + 1 
        r.total_bikes = r.total_bikes + entity.available_bike 
        r.total_slots = r.total_slots + entity.available_spaces
        r.average_bikes = r.total_bikes / r.samples
        r.average_slots = r.total_slots / r.samples
        r.put()

    db.run_in_transaction(accumulate_averages, hour, day_of_week, key, entity)
    yield op.counters.Increment(entity.sid)