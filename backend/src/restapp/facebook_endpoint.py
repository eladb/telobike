import restapp
import facebook

class AuthenticatedEndpoint(restapp.Endpoint):
    """A Facebook-authenticated endpoint.
    All requests that have a fb_access_token parameter will be validated with facebook
    and the facebook 'me' dictionary will be added to the context
    """
    def authenticate_request(self, ctx):
        """Authenticates a request with facebook (in case it has an fb_access_token parameter.
        Args:
            ctx - The request context
        Returns:
            The facebook 'me' object
        """
        fb_access_token = ctx.request.get('fb_access_token')
        if fb_access_token:
            fbquery = facebook.FacebookQuery()
            me = fbquery.me_from_token(fb_access_token)
            
            if not me:
                raise restapp.errors.UnauthorizedRequestError('Invalid authentication token (%d): %s' % (fbquery.last_response.status_code, fbquery.last_response.content))
            
            if me: me['access_token'] = fb_access_token
            return me
        return None