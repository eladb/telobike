class RequestError(Exception):
    """Thrown when a request handler wants to propagate an error to the user
    Properties:
        code - http error code
        body - message to be emitted
    """
    def __init__(self, code = 500, body = 'Internal server error'):
        self.code = code
        self.body = body

class BadRequestError(RequestError):
    def __init__(self, body = "Bad request"):
        super(self.__class__, self).__init__(400, "Bad request: %s" % body)

class NotFoundError(RequestError):
    def __init__(self, body = "Not found"):
        super(self.__class__, self).__init__(404, "Bad request: %s" % body)

class UnauthorizedRequestError(RequestError):
    def __init__(self, body = "Unauthorized"):
        super(self.__class__, self).__init__(401, "Unauthorized: %s" % body)
