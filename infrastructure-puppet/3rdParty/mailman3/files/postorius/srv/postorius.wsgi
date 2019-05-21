import os
import site

# project root directory (one above `srv`)
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

# prepend root dir to python path
site.addsitedir(root_dir)

os.environ['DJANGO_SETTINGS_MODULE'] = 'local_settings'

# use for django 1.8.x
#import django.core.handlers.wsgi

#application = django.core.handlers.wsgi.WSGIHandler()

# use for django 1.7.x
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
