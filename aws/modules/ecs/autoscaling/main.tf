locals {
  # TODO set and link puma thread count here
  service_thread_count = 5

  # TODO link puma worker count here
  service_worker_count = 2

  # TODO document
  service_worst_case_response_time = 1

  # TODO link aws documentation here
  #
  # ALBRequestCountPerTarget is the average request
  # count per alb target over 5min
  #
  request_count_metric_time_window = 5 * 20

  # This calculates a rough estimate of the number of
  # requests a container should be able to serve in
  # the `request_count_metric_time_window`.
  #
  # We estimate based on the number of processes,
  # threads per process and estimated response time.
  #
  request_count_auto_scaling_target_value = local.request_count_metric_time_window * local.service_thread_count * local.service_worker_count * local.service_worst_case_response_time
}

resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

resource "aws_appautoscaling_policy" "request_count_tracking_policy" {
  name        = var.name
  resource_id = aws_appautoscaling_target.target.resource_id

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value = local.request_count_auto_scaling_target_value

    # TODO
    disable_scale_in = false

    scale_in_cooldown  = var.autoscaling_cooldown
    scale_out_cooldown = var.autoscaling_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.alb_arn_suffix}/${var.target_group_arn_suffix}"
    }
  }
}
