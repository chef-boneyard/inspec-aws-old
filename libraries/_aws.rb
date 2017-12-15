# Main AWS loader file.  The intent is for this to be 
# loaded only if AWS resources are needed.

require 'aws-sdk'
require '_aws_backend_factory_mixin'
require '_aws_resource_mixin'
require '_aws_connection'
