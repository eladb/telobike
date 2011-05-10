"""Creates an HTML page that describes the API of the application"""

class RequestDoc:
    url = ''
    doc = ''
    usage = ''
    usages = []
    title = ''
    
    def __init__(self, reqCls = None):
        if reqCls:
            self.url = reqCls.get_url()
            
            doc = ''
            if reqCls.__doc__: doc = reqCls.__doc__
    
            doclines = doc.splitlines()
    
            self.doc = '\n'.join(doclines[1:])
            self.title = doclines[0]
            
            self.usages = reqCls.get_usages()
            self.usage = self.usages[0].usage

class UsageDoc:
    usage = ''
    doc = ''
    sample = ''
    method = 'GET'
    anchor = None
    args = []
    def __init__(self, usage = None, doc = None, sample = None, method = 'GET', args = []):
        self.method = method
        self.usage = usage
        if doc: self.doc = doc
        else: self.doc = ''
        if sample: self.sample = sample
        else: self.sample = ''
        self.args = args
        
class UsageArgument:
    name = ''
    doc = ''
    format = ''
    sample = ''
    optional = False
    def __init__(self, name, format = 'string', doc = '', sample = '', optional = False):
        self.name = name
        self.format = format
        self.doc = doc
        self.sample = sample
        self.optional = optional
