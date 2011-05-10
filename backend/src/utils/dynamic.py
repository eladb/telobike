def get_class_full(full_class_name):
    """Returns a class object from a full class name ('module.class')"""
    module_name, _, class_name = full_class_name.rpartition('.')
    if module_name == '':
        raise ValueError('Class name must contain module part')
    
    return get_class(module_name, class_name)

def get_class(module_name, class_name):
    """Returns a class object from a module name and class name"""
    return getattr(__import__(module_name, globals(), locals(), [class_name], -1), class_name)

def new_object_from_full_class_name(full_class_name):
    """Instantiates an object from a full class name ('module.class')"""
    cls = get_class_full(full_class_name)
    return cls()

def new_object(module_name, class_name):
    """Instantiates a new object from module name and class name"""
    cls = get_class(module_name, class_name)
    return cls()

def full_class_name_for_class(cls):
    return "%s.%s" % (cls.__module__, cls.__name__)

def full_class_name(obj):
    return full_class_name_for_class(obj.__class__)
