#------------------------------------------------------------------------------
# AWS ECS Auto Scaling - CloudWatch Alarm MEMORY High
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.cluster_name}-${var.service_name}-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = var.memory_high_threshold
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.memory_step_scaling_up_policy.arn]

  tags = var.tags
}

#------------------------------------------------------------------------------
# AWS ECS Auto Scaling - CloudWatch Alarm MEMORY Low
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name          = "${var.cluster_name}-${var.service_name}-memory-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "6"
  datapoints_to_alarm = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.memory_low_threshold
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.memory_step_scaling_down_policy.arn]

  tags = var.tags
}

## WIP MEMORY Utilization Step Scaling Scale UP Policy

resource "aws_appautoscaling_target" "memory_step_up" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

resource "aws_appautoscaling_policy" "memory_step_scaling_up_policy" {
  name               = "${var.name}-memory-scale-up"
  resource_id        = aws_appautoscaling_target.memory_step_up.resource_id
  scalable_dimension = aws_appautoscaling_target.memory_step_up.scalable_dimension
  service_namespace  = aws_appautoscaling_target.memory_step_up.service_namespace

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

## WIP MEMORY Utilization Step Scaling Scale DOWN Policy

resource "aws_appautoscaling_target" "memory_step_down" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

resource "aws_appautoscaling_policy" "memory_step_scaling_down_policy" {
  name               = "${var.name}-memory-scale-down"
  resource_id        = aws_appautoscaling_target.memory_step_down.resource_id
  scalable_dimension = aws_appautoscaling_target.memory_step_down.scalable_dimension
  service_namespace  = aws_appautoscaling_target.memory_step_down.service_namespace

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
