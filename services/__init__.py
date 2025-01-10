import os
import json
from flask import make_response


def root_dir():
    """
    Returns the root directory for this project.
    Useful for locating files relative to the project root.
    """
    return os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))


def nice_json(arg):
    response = make_response(json.dumps(arg, sort_keys = True, indent=4))
    response.headers['Content-type'] = "application/json"
    return response