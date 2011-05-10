import datetime

def parse_timestamp(s):
    if s == None: return None
    if isinstance(s, datetime.datetime): return s   # idempotent for datetimes
    if s.lower() == 'now': return utcnow()          # support 'now'
    
    allowed_formats = [ '%Y-%m-%d %H:%M:%S.%f', 
                        '%Y-%m-%d %H:%M:%S',
                        '%Y-%m-%d %H:%M',
                        '%Y-%m-%d',
                        '%m/%d/%Y',
                        '%m/%d/%Y %H:%M:%S' ]
    
    ts = None
    
    for fmt in allowed_formats:
        try: 
            ts = datetime.datetime.strptime(s, fmt)
            break
        except ValueError: 
            pass
    
    return ts

def utcnow():
    return datetime.datetime.utcnow()

def format(t):
    return t.strftime('%Y-%m-%d %H:%M:%S.%f')

def formatted_now():
    return format(utcnow())

def total_seconds(timedelta):
    """Calculates the total number of seconds in a timedelta object"""
    td = timedelta
    total_seconds = (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10**6
    return total_seconds
