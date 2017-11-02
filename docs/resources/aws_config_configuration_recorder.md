---
title: About the aws_config_configuration_recorder Resource
---

# aws_config_configuration_recorder

Use the `aws_config_configuration_recorder` InSpec audit resource to test properties of the AWS Config service settings in the current region.  A Configuration Recorder determines what changes are monitored, and uses a Delivery Channel to store the changes.  This resource is usually used in conjunction with `aws_config_delivery_channel`.

AWS currently allows at most one configuration recorder per region.  By default, its name is 'default'.

<br>

## Examples

    # Verify the default configuration recorder exists
    describe aws_config_configuration_recorder do
      it { should exist }
    end

    # Verify your custom-named configuration recorder 
    # is watching changes to all regional AWS resources
    describe aws_config_configuration_recorder('my-recorder') do
      it { should be_recording_all_regional_changes }
    end

## Matchers

### exist

TODO

### be_enabled

TODO

### be_recording_all_regional_changes

TODO

### be_recording_all_global_changes

TODO

## Properties

This InSpec resource has no custom properties.