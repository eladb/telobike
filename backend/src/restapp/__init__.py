import os
import logging

from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from django.utils import simplejson as json

import context
import errors

class Endpoint(object):
    """Represents a REST endpoint"""

    def query(self, ctx):
        """Handler for GET requests. This handler should perform a query using any
        query parameters in the context
        Args:
            ctx - Request context.
        Returns:
            An object that will later be formatted using one of the 'alt' methods.
        """
        raise NotImplementedError()
    
    def get(self, ctx):
        """Handler for a GET request for a single resource. The handler return
        Args:
            ctx - request context
        Returns:
            An object that will later be formatted using one of the 'alt' methods.
            This could also be a tuple, in which case the first one should be a dictionary 
            or any other type serializable to JSON and the second one can be any type
            which will be passed to the alt_Xxx methods.
        """
        raise NotImplementedError()
    
    def post(self, ctx):
        """Handler for POST requests. POST request should create a new resource
        using data from the POST fields in the context.
        Args:
            ctx - request context
        Returns:
            A string that contains the key for the new created resource.
            This string will be used to redirect the user to the newly created resource
        """
        raise NotImplementedError()
    
    def authenticate_request(self, ctx):
        """Called to authenticate a request. By default, does nothing.
        Args:
            ctx - The request context
        Returns:
            The authentication context which will be incorporated into the context.
        """
        return None

    def alt_json(self, ctx, obj):
        """Emits a JSON representation of the response dictionary into the response object
        Args:
            ctx - The request context
            obj - The object or tuple returned by a GET handler (if tuple, the first item is taken)
        """
        if isinstance(obj, tuple):
            obj = obj[0]

        ctx.response.headers['Content-Type'] = "application/json"
        ctx.response.out.write(json.dumps(obj, indent=4, sort_keys=True))
    
    def alt_html(self, ctx, obj):
        """Creates an HTML representation of a response object.
        This is done by looking for a template .html file and passing it the response object
        Args:
            ctx - The request context
            obj - The object or tuple returned by a GET handler (if tuple, only the first item is taken)
        """
        if isinstance(obj, tuple):
            obj = obj[0]

        name = ctx.endpoint_name.lower()
        if name.endswith('endpoint'): 
            name = name[:name.rfind('endpoint')]
        template_name = '%s.html' % name
        path = os.path.join(os.path.dirname(ctx.endpoint_file), template_name)
        if not os.path.exists(path):
            ctx.response.set_status(404)
            ctx.response.out.write('unable to find file: %s' % path)
            return
        ctx.response.out.write(template.render(path, obj))
    
class RequestHandler(webapp.RequestHandler):
    """Handler that handles REST requests for a specified endpoint"""
    
    def __init__(self, root_path, endpoint_class, default_alt = 'html'):
        """Constructor.
        Args:
          endpoint_class: The class that implements the endpoint
          default_alt: The default 'alt' representation to be used if no '?alt' argument is specified 
          root_path_position: The position of the path root
                              E.g: if the URLs look like this '/user/xxx' the root
                              is the 'user' and it's position is 1.
        """
        self.endpoint_class = endpoint_class
        self.endpoint = self.endpoint_class()
        self.root_path = root_path.rstrip('/')
        self.root_path_position = len(filter(lambda x: x, root_path.split('/'))) # calculate position of root path
        self.default_alt = default_alt
    
    def get(self):
        """Handles GET requests by propogating them to the endpoint object."""
        
        def safe_get(ctx):
            response_obj = None
    
            # determine if this is a query or a single entity get
            if not ctx.resource_path: # query
                try:
                    response_obj = self.endpoint.query(ctx)
                except NotImplementedError:
                    raise errors.BadRequestError('GET is not supported for this endpoint')
            else: # single entity
                try:
                    response_obj = self.endpoint.get(ctx)
                except NotImplementedError:
                    raise errors.BadRequestError('GET is not supported for this endpoint')
    
            # determine representation and invoke the 'alt' method which emits 
            # output to into the response object
            alt = self.request.get('alt', default_value = self.default_alt)
            self._invoke_alt_method(alt, ctx, response_obj)
            
        self._with_error_handling(safe_get)
        
    def post(self):
        """Handles POST requests by propagating them to the endpoint object."""

        def safe_post(ctx):
            try:
                new_resource = self.endpoint.post(ctx)
                self.redirect('%s/%s' % (self.root_path, new_resource))
            except NotImplementedError:
                self.error(400)
                self.response.out.write('POST is not supported for this endpoint')

        self._with_error_handling(safe_post)
    
    def _with_error_handling(self, code):
        """Runs 'code()' with request error handling.
        Args:
            code - The method to run
        """
        try:
            ctx = self._create_context()
            auth_ctx = self.endpoint.authenticate_request(ctx)
            ctx.auth_context = auth_ctx
            code(ctx)
        except errors.RequestError, e:
            logging.error('%d: %s' % (e.code, e.body))
            self.error(e.code)
            self.response.out.write(e.body)
    
    def _create_context(self):
        """Creates a request context"""
        return context.RequestContext(request = self.request, 
                                      response = self.response, 
                                      endpoint_class = self.endpoint_class,
                                      root_path_position = self.root_path_position,
                                      root_path = self.root_path)
    
    def _invoke_alt_method(self, alt, ctx, obj):
        """Invokes the alt_XXX method based on a string
        
        Args:
            alt - An 'alt' string (e.g. 'html', 'json', ...)
            respctx - The response context
        """
        
        alt_method = getattr(self.endpoint, 'alt_%s' % alt.lower(), None)
        if not alt_method:
            self.error(400)
            self.response.out.write('unable to represent resource in format: %s' % alt)
            return

        alt_method(ctx, obj)        
        