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
  request_count_metric_time_window = 5 * 60

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

# TODO I really dont know what is here - just had to make it work quick (tom 30.12.2020)
resource "aws_appautoscaling_policy" "request_count_tracking_policy" {
  name               = var.name
  resource_id        = aws_appautoscaling_target.target.resource_id
  scalable_dimension = aws_appautoscaling_target.target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
