# CloudFormation Launch Template and Auto Scaling Group

This repository contains a CloudFormation template and a bash script to create an EC2 Launch Template and Auto Scaling Group (ASG) in AWS. The CloudFormation template deploys the necessary resources, while the script allows you to customize the parameters for the deployment.

# Launch stack directly in AWS

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?templateURL=https://prasanna-glacier-dev.s3.us-east-1.amazonaws.com/asg_creator.yml)


## Overview

### CloudFormation Template
- **Launch Template:** Creates an EC2 Launch Template using a `t3.micro` instance size.
- **Auto Scaling Group (ASG):** Sets up an Auto Scaling Group using the created Launch Template. You can specify the desired capacity, maximum size, and other parameters in the CloudFormation stack.

## Prerequisites

- **AWS CLI**: Ensure the AWS CLI is installed and configured with appropriate credentials.
- **AWS CloudFormation**: Access to create stacks and deploy resources.
- **Bash**: The script uses bash to accept parameters and deploy the stack.

## Usage

```bash
chmod +x asg_creator.sh
sh asg_creator.sh -n <name> -s <desired_size> -u <subnet_list>
