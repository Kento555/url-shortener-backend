resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = "WAF for API Gateway to allow only specific IPs"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-metrics"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "allow-only-my-ip"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allow_ip.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-allow-ip"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Environment = var.env
    Project     = "url-shortener"
  }
}

resource "aws_wafv2_ip_set" "allow_ip" {
  name               = "${var.name}-allowed-ip"
  description        = "Allowed IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = var.allowed_ips
}

resource "aws_wafv2_web_acl_association" "api" {
  resource_arn = var.api_gw_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn

  depends_on = [aws_wafv2_web_acl.this, var.api_gw_stage_arn]
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "/aws/waf/${var.name}"
  retention_in_days = 7
}

resource "aws_wafv2_web_acl_logging_configuration" "logging" {
  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]

  depends_on = [aws_cloudwatch_log_group.waf_logs]

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }
    }
  }
}
