## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of each
# stage's management account, not any other account nor region.

## -------------------------------------------------------------------------------------
## COST ANOMALY DETECTION
## -------------------------------------------------------------------------------------

# To start, the simplest approach is to create a single service monitor per stage in
# each stage's management account to detect anomalies across the entire org. In the
# future, it's probably worth creating separate service monitors in each account and/or
# creating monitors of a different type in each stage's management account for more
# granular anomaly detection.
resource "aws_ce_anomaly_monitor" "main" {
  name = "main-${var.stage}"

  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "main" {
  name = "main-${var.stage}"

  monitor_arn_list = [aws_ce_anomaly_monitor.main.arn]

  # To start, the simplest approach is to configure "DAILY" frequecy because it doesn't
  # require an SNS topic to be created. In the future, it's probably worth changing to
  # "IMMEDIATE".
  frequency = "DAILY"

  subscriber {
    type    = "EMAIL"
    address = "devshrekops+demo-mgmt-${var.stage}@gmail.com"
  }

  # Both thresholds must be exceed before an alert is sent
  threshold_expression {
    # The absolute threshold is the dollar amount that must be exceeded in actual spend
    # before an alert will be sent. The monthly AWS bill is currently less than a dollar
    # in each stage's org, so a very low threshold is hardcoded that applies to every
    # stage. In a real deployment, the thresholds will be much higher, and it should be
    # possible to set different thresholds in different stages via an input variable.
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = ["5"]
      }
    }

    # The percentage threshold is the percentage that actual spend must exceed predicted
    # spend (based on Cost Anomaly Detection's machine learning models) before an alert
    # will be sent. Generally speaking, the higher the absolute threshold is, the lower
    # the percentage threshold should be.
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = ["50"]
      }
    }
  }
}
