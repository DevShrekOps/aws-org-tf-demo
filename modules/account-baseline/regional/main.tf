## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will be created in each enabled region of
# each account in each stage.

## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Fetch the current region
data "aws_region" "main" {}

# Store as local value for easier referencing
locals {
  region = data.aws_region.main.name
}

## -------------------------------------------------------------------------------------
## CONFIG RECORDER & DELIVERY CHANNEL
## -------------------------------------------------------------------------------------

# I would've preferred to declare these resources in the standalone config capability so
# that they're declared side-by-side with other Config-related resources, but because
# they need to be created in each account, it's more practical to declare them here
# instead. Otherwise, the config capability modules would have to be updated with new
# AWS providers each time a new account was created in the org.

locals {
  # Reduce costs by excluding resources that are created by default in all accounts but
  # which aren't being used in this demo. In a real deployment, it's probably best to
  # record all supported resources and eat the extra cost, at least in prod.
  config_resource_types_to_exclude_in_all_regions = [
    "AWS::AppConfig::DeploymentStrategy",
    "AWS::Athena::WorkGroup",
    "AWS::Cassandra::Keyspace",
    "AWS::CodeDeploy::DeploymentConfig",
    "AWS::ECS::CapacityProvider",
  ]

  # In regions other than us-east-1, in addition to excluding the resources above, also
  # exclude global resources so that they're only recorded a single time per account.
  config_resources_to_exclude_in_secondary_regions = concat(
    local.config_resource_types_to_exclude_in_all_regions,
    [
      "AWS::IAM::Group",
      "AWS::IAM::InstanceProfile",
      "AWS::IAM::Policy",
      "AWS::IAM::Role",
      "AWS::IAM::SAMLProvider",
      "AWS::IAM::User",
      "AWS::S3::AccountPublicAccessBlock",
    ]
  )
}

resource "aws_config_configuration_recorder" "main" {
  name     = "main-${var.stage}"
  role_arn = var.config_svc_role_arn

  recording_group {
    all_supported = false

    recording_strategy {
      use_only = "EXCLUSION_BY_RESOURCE_TYPES"
    }

    exclusion_by_resource_types {
      resource_types = (
        local.region == "us-east-1" ?
        local.config_resource_types_to_exclude_in_all_regions :
        local.config_resources_to_exclude_in_secondary_regions
      )
    }
  }

  recording_mode {
    # Continuous recording is better for security & compliance compared to daily
    # recording. However, it's potentially expensive in accounts with frequent updates
    # to resources. If costs get out of hand, then it's probably best to override the
    # recording frequency of frequently-updated resource types to daily, or even change
    # the default to daily, at least for non-prod stages.
    recording_frequency = "CONTINUOUS"
  }
}

resource "aws_config_delivery_channel" "main" {
  name = "main-${var.stage}"

  # This bucket is created in each stage's security account by the config capability.
  # I'm not crazy about hardcoding the bucket name here, but I'm even less crazy about
  # all the other methods of fetching or passing in the bucket name. Maybe I'll change
  # my mind in the future and refactor this, but in the meantime, I'll simply add a
  # comment above the resource declaration for this bucket noting that if its name is
  # ever changed, then this reference to it must be updated as well.
  s3_bucket_name = "devshrekops-demo-config-logs-${var.stage}"

  snapshot_delivery_properties {
    # By default, Config only delivers configuration history files to the S3 bucket, not
    # configuration snapshot files. Setting the delivery frequency here enables snapshot
    # files to be delivered too. History files are delivered every 6 hours, but only
    # include configuration items for resources that changed since the last delivery.
    # Snapshots are delivered every 24 hours (per the below) and contain the
    # configuration items for all supported resources, regardless of when they last
    # changed.
    delivery_frequency = "TwentyFour_Hours"
  }

  # AWS requires that the Config recorder exists before the delivery channel can be
  # created, but Terraform isn't able to infer that dependency, since none of the
  # delivery channel's arguments reference the recorder, so the dependency must be
  # explicitly configured.
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  # AWS requires that the Config delivery channel exists before the recorder can be
  # enabled, but Terraform isn't able to infer that dependency, since none of the
  # recorder status' arguments reference the delivery channel, so the dependency must be
  # explicitly configured.
  depends_on = [aws_config_delivery_channel.main]
}
