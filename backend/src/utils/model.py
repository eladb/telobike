from google.appengine.api import datastore_types

def to_dict(model, keyname = None):
    """Converts a model object to a dictionary
    Args:
        model - a model object
        keyname - the key to use if you want to incoporate the model's key name in the dictionary
    Returns:
        A dictionary.
    """
    
    d = dict()
    
    for prop_name in model.properties():
        prop_value = getattr(model, prop_name)

        if prop_value:
            if prop_value.__class__ == datastore_types.Blob: 
                continue # skip blobs
            
            if getattr(prop_value, '__iter__', False): 
                d[prop_name] = prop_value # do not stringify iterables
            else: 
                d[prop_name] = unicode(prop_value)

    if keyname:
        d[keyname] = model.key().name()

    return d    