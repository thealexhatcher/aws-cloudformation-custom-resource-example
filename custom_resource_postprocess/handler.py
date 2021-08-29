from crhelper import CfnResource

helper = CfnResource()

@helper.create
@helper.update
def postprocessor(event, _):
    helper.Data['Message'] = "Goodbye!"
@helper.delete
def no_op(_, __):
    pass

def function(event, context):
    helper(event, context)