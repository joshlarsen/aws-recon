## Terraform Setup

This is an example module that can be used in its current form or modified for your specific environment. It builds the minimum components necessary to collect inventory on a schedule running AWS Recon as a Fargate scheduled task.

### Requirements

Before running this Terraform module, adjust your region accordingly in `main.tf`.

### What is created?

This Terraform example will deploy the following resources:

- an S3 bucket to store compressed JSON output files
- an IAM role for ECS task execution
- a Security Group for the ECS cluster/task
- a VPC and NGW for the ECS cluster/task
- an ECS/Fargate cluster
- an ECS task definition to run AWS Recon collection
- a CloudWatch event rule to trigger the ECS task
- a CloudTrail log group for ECS task logs
