## Deploy sonarqube docker image on AWS ECS

### Resources
* Creates ECS cluster using official ecs terraform module
* Creates ECS service
* Creates ALB and ssl/TLS configuration with AWS certificate manager
* Creates RDS postgressdb
* Uses AWS secret manager for passing the postgress details to ECS task definition
