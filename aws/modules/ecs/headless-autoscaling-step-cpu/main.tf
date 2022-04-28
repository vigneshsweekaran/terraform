#------------------------------------------------------------------------------
# AWS ECS Auto Scaling - CloudWatch Alarm CPU High
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.cluster_name}-${var.service_name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.cpu_step_scaling_up_policy.arn]

  tags = var.tags
}

#------------------------------------------------------------------------------
# AWS ECS Auto Scaling - CloudWatch Alarm CPU Low
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.cluster_name}-${var.service_name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "6"
  datapoints_to_alarm = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.cpu_low_threshold
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.cpu_step_scaling_down_policy.arn]

  tags = var.tags
}

## WIP CPU Utilization Step Scaling Scale UP Policy

resource "aws_appautoscaling_target" "cpu_step_up" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

resource "aws_appautoscaling_policy" "cpu_step_scaling_up_policy" {
  name               = "${var.name}-cpu-scale-up"
  resource_id        = aws_appautoscaling_target.cpu_step_up.resource_id
  scalable_dimension = aws_appautoscaling_target.cpu_step_up.scalable_dimension
  service_namespace  = aws_appautoscaling_target.cpu_step_up.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_up_cooldown
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 20
      scaling_adjustment          = 2
    }

    step_adjustment {
      metric_interval_lower_bound = 20
      metric_interval_upper_bound = 30
      scaling_adjustment          = 1
    }

    step_adjustment {
      metric_interval_lower_bound = 30
      scaling_adjustment          = 2
    }
  }
}

## WIP CPU Utilization Step Scaling Scale DOWN Policy

resource "aws_appautoscaling_target" "cpu_step_down" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

resource "aws_appautoscaling_policy" "cpu_step_scaling_down_policy" {
  name               = "${var.name}-cpu-scale-down"
  resource_id        = aws_appautoscaling_target.cpu_step_down.resource_id
  scalable_dimension = aws_appautoscaling_target.cpu_step_down.scalable_dimension
  service_namespace  = aws_appautoscaling_target.cpu_step_down.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_down_cooldown
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
