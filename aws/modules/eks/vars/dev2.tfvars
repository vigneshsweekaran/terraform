region     = "us-east-1"
access_key = ""
secret_key = ""

instance_type              = "t2.medium"
node_autoscaling_min       = 1
node_autoscaling_desired   = 1
node_autoscaling_max       = 3

eks_cluster_role           = ""
eks_node_group_role        = ""
fargate_pod_execution_role = ""
fp_namespaces              = ["default", "gitlab-executor", "dev2"]
