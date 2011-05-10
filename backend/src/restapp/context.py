"""Request and response context objects for the respapp framework"""

import inspect
import errors


class RequestContext(object):
    """Represents a request context"""
    def __init__(self, request, response, endpoint_class, root_path_position, root_path):
        """Constructor.
        
        Args:
            request: the request object
            response: the response object
            endpoint_class: the class that implements the endpoint
            resource_path: the path to the resource
        """
        self.endpoint_name = endpoint_class.__name__.lower()
        self.endpoint_file = inspect.getfile(endpoint_class)
        self.request = request
        self.response = response
        self.root_path_position = root_path_position
        self.root_path = root_path
        self.resource_path = self._get_resource_path()
        self.auth_context = None

    def require(self, key, msgfmt = "missing required argument '%s'"):
        """Tries to retrieve an argument from the request and if
        it was not provided, raises a bad request.
        Args:
            key - The GET/POST parameter name
            message - The message to emit with the error
        """
        val = self.request.get(key)
        if not val or val == '':
            raise errors.BadRequestError(msgfmt % key);
        return val
    
    def require_auth(self, message = "Request must be authenticated"):
        """Requires that a request be authenticated (that the auth_context will not be None).
        If not, an unauthorized response is returned
        Returns:
            The authentication context.
        """
        if not self.auth_context:
            raise errors.UnauthorizedRequestError("Request must be authenticated")
        return self.auth_context

    def _get_resource_path(self):
        """Splits the request path and returns the path after the endpoint root
        Returns:
            The entire path after the endpoint root.
            If the path contains multiple parts, it is returned as an array.
            If the path contains a single part, it is returned as a single string value.
        """
        parts = filter(lambda x: x, self.request.path.split('/'))
        if len(parts) <= self.root_path_position:
            return None
        ret = parts[1:]
        if len(ret) == 1: return ret[0]
        else: return ret
