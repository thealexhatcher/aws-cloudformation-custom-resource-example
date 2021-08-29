from crhelper import CfnResource
import logging

logger = logging.getLogger(__name__)
# Initialise the helper, all inputs are optional, this example shows the defaults
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL', sleep_on_delete=120, ssl_verify=None)

@helper.create
@helper.update
def preprocessor(event, _):
    helper.Data['Message'] = "Hello!"
@helper.delete
def no_op(_, __):
    pass

def function(event, context):
    helper(event, context)
