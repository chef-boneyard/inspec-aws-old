describe aws_cloudformation_stack do
  its('entries') { should eq [] }
end

describe aws_cloudformation_stack.where { stack_status != 'CREATE_COMPLETE'} do
  its('entries') { should eq []}
end
