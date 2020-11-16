[![Gem Version](https://badge.fury.io/rb/aws_recon.svg)](https://badge.fury.io/rb/aws_recon)

# AWS Recon

A multi-threaded AWS inventory collection tool.

The [creators](https://darkbit.io) of this tool have a recurring need to be able to efficiently collect a large amount of AWS resource attributes and metadata to help clients understand their cloud security posture.

There are a handful of tools (e.g. [AWS Config](https://aws.amazon.com/config), [CloudMapper](https://github.com/duo-labs/cloudmapper), [CloudSploit](https://github.com/cloudsploit/scans), [Prowler](https://github.com/toniblyx/prowler)) that do some form of resource collection to support other functions. But we found we needed broader coverage and more details at a per-service level. We also needed a consistent and structured format that allowed for integration with our other systems and tooling.

Enter AWS Recon, multi-threaded AWS inventory collection tool written in plain Ruby. Though most AWS tooling tends to be dominated by Python, the [Ruby SDK](https://aws.amazon.com/sdk-for-ruby/) is quite mature and capable. The maintainers of the Ruby SDK have done a fantastic job making it easy to handle automatic retries, paging of large responses, and threading huge numbers of requests.

## Project Goals

- More complete resource coverage than available tools (especially for ECS & EKS)
- More granular resource detail, including nested related resources in the output
- Flexible output (console, JSON lines, plain JSON, file, standard out)
- Efficient (multi-threaded, rate limited, automatic retries, and automatic result paging)
- Easy to maintain and extend

## Setup

### Requirements

Ruby 2.5.x or 2.6.x (developed and tested with 2.6.5)

### Installation

AWS Recon can be run locally by installing the Ruby gem, or via a Docker container.

To run locally, first install the gem:

```
$ gem install aws_recon
Fetching aws_recon-0.2.8.gem
Fetching aws-sdk-resources-3.76.0.gem
Fetching aws-sdk-3.0.1.gem
Fetching parallel-1.19.2.gem
...
Successfully installed aws-sdk-3.0.1
Successfully installed parallel-1.19.2
Successfully installed aws_recon-0.2.8
```

Or add it to your Gemfile using `bundle`:

```
$ bundle add aws_recon
Fetching gem metadata from https://rubygems.org/
Resolving dependencies...
...
Using aws-sdk 3.0.1
Using parallel 1.19.2
Using aws_recon 0.2.8
```

To run via a Docker a container, pass the necessary AWS credentials into the Docker `run` command. For example:

```
$ docker run -t --rm \
  -e AWS_REGION \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  -v $(pwd)/output.json:/recon/output.json \
  darkbitio/aws_recon:latest \
  aws_recon -v -s EC2 -r global,us-east-1,us-east-2
```


## Usage

AWS Recon will leverage any AWS credentials currently available to the environment it runs in. If you are collecting from multiple accounts, you may want to leverage something like [aws-vault](https://github.com/99designs/aws-vault) to manage different credentials. 

```
$ aws-vault exec profile -- aws_recon
```

Plain environment variables will work fine too.

```
$ AWS_PROFILE=<profile> aws_recon
```

To run from a Docker container using `aws-vault` managed credentials (output to stdout):

```
$ aws-vault exec <vault_profile> -- docker run -t --rm \
  -e AWS_REGION \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  darkbitio/aws_recon:latest \
  aws_recon -j -s EC2 -r global,us-east-1,us-east-2
```

To run from a Docker container using `aws-vault` managed credentials and output to a file, you will need to satisfy a couple of requirements. First, Docker needs access to bind mount the path you specify (or a parent path above). Second, you need to create an empty file to save the output into (e.g. `output.json`). This is because we are only mounting that one file into the Docker container at run time. For example:

Create an empty file.

```
$ touch output.json
```

Run the `aws_recon` container, specifying the output file.

```
$ aws-vault exec <vault_profile> -- docker run -t --rm \
  -e AWS_REGION \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  -v $(pwd)/output.json:/recon/output.json \
  darkbitio/aws_recon:latest \
  aws_recon -s EC2 -v -r global,us-east-1,us-east-2
```

You may want to use the `-v` or `--verbose` flag initially to see status and activity while collection is running. 

In verbose mode, the console output will show:

```
<thread>.<region>.<service>.<operation>
```

The `t` prefix indicates which thread a particular request is running under. Region, service, and operation indicate which request operation is currently in progress and where.

```
$ aws_recon -v

t0.global.EC2.describe_account_attributes
t2.global.S3.list_buckets
t3.global.Support.describe_trusted_advisor_checks
t2.global.S3.list_buckets.acl
t5.ap-southeast-1.WorkSpaces.describe_workspaces
t6.ap-northeast-1.Lightsail.get_instances
...
t2.us-west-2.WorkSpaces.describe_workspaces
t1.us-east-2.Lightsail.get_instances
t4.ap-southeast-1.Firehose.list_delivery_streams
t7.ap-southeast-1.Lightsail.get_instances
t0.ap-south-1.Lightsail.get_instances
t1.us-east-2.Lightsail.get_load_balancers
t7.ap-southeast-2.WorkSpaces.describe_workspaces
t2.eu-west-3.SageMaker.list_notebook_instances
t3.eu-west-2.SageMaker.list_notebook_instances

Finished in 46 seconds. Saving resources to output.json.
```

#### Example command line options

```
$ AWS_PROFILE=<profile> aws_recon -s S3,EC2 -r global,us-east-1,us-east-2
```

```
$ AWS_PROFILE=<profile> aws_recon --services S3,EC2 --regions global,us-east-1,us-east-2
```

Example [OpenCSPM](https://github.com/OpenCSPM/opencspm) formatted output.

```
$ AWS_PROFILE=<profile> aws_recon -s S3,EC2 -r global,us-east-1,us-east-2 -f custom > output.json
```

#### Errors

An exception will be raised on `AccessDeniedException` errors. This typically means your user/role doesn't have the necessary permissions to get/list/describe for that service. These exceptions are raised so troubleshooting access issues is easier.

```
Traceback (most recent call last):
arn:aws:sts::1234567890:assumed-role/role/9876543210 is not authorized to perform: codepipeline:GetPipeline on resource: arn:aws:codepipeline:us-west-2:876543210123:pipeline (Aws::CodePipeline::Errors::AccessDeniedException)
```

The exact API operation that triggered the exception is indicated on the last line of the stack trace. If you can't resolve the necessary access, you should exclude those services with `-x` or `--not-services` so the collection can continue.

### Threads

AWS Recon uses multiple threads to try to overcome some of the I/O challenges of performing many API calls to endpoints all over the world.

For global services like IAM, Shield, and Support, requests are not multi-threaded. The S3 module is multi-threaded since each bucket requires several additional calls to collect complete metadata.

For regional services, a thread (up to the thread limit) is spawned for each service in a region. By default, up to 8 threads will be used. If your account has resources spread across many regions, you may see a speed improvement by increasing threads with `-t X`, where `X` is the number of threads.

### Options

Most users will want to limit collection to relevant services and regions. Running without any options will attempt to collect all resources from all 16 regular regions.

```
$ aws_recon -h

AWS Recon - AWS Inventory Collector (0.2.8)

Usage: aws_recon [options]
    -r, --regions [REGIONS]          Regions to scan, separated by comma (default: all)
    -n, --not-regions [REGIONS]      Regions to skip, separated by comma (default: none)
    -s, --services [SERVICES]        Services to scan, separated by comma (default: all)
    -x, --not-services [SERVICES]    Services to skip, separated by comma (default: none)
    -c, --config [CONFIG]            Specify config file for services & regions (e.g. config.yaml)
    -o, --output [OUTPUT]            Specify output file (default: output.json)
    -f, --format [FORMAT]            Specify output format (default: aws)
    -t, --threads [THREADS]          Specify max threads (default: 8, max: 128)
    -u, --user-data                  Collect EC2 instance user data (default: false)
    -z, --skip-slow                  Skip slow operations (default: false)
    -j, --stream-output              Stream JSON lines to stdout (default: false)
    -v, --verbose                    Output client progress and current operation
    -d, --debug                      Output debug with wire trace info
    -h, --help                       Print this help information

```

#### Output

Output is always some form of JSON - either JSON lines or plain JSON. The output is either written to a file (the default), or written to stdout (with `-j`).


## Supported Services & Resources

Current "coverage" by service is listed below. The services without coverage will eventually be added. PRs are certainly welcome. :)

AWS Recon aims to collect all resources and metadata that are relevant in determining the security posture of your AWS account(s). However, it does not actually examine the resources for security posture - that is the job of other tools that take the output of AWS Recon as input.

- [x] AdvancedShield
- [x] Athena
- [x] GuardDuty
- [ ] Macie
- [x] Systems Manager
- [x] Trusted Advisor
- [x] ACM
- [x] API Gateway
- [x] AutoScaling
- [x] CodePipeline
- [x] CodeBuild
- [x] CloudFormation
- [x] CloudFront
- [x] CloudWatch
- [x] CloudWatch Logs
- [x] CloudTrail
- [x] Config
- [x] DirectoryService
- [x] DirectConnect
- [x] DMS
- [x] DynamoDB
- [x] EC2
- [x] ECR
- [x] ECS
- [x] EFS
- [x] ELB
- [x] EKS
- [x] Elasticsearch
- [x] ElastiCache
- [x] Firehose
- [ ] FMS
- [ ] Glacier
- [x] IAM
- [x] KMS
- [x] Kafka
- [x] Kinesis
- [x] Lambda
- [x] Lightsail
- [x] Organizations
- [x] RDS
- [x] Redshift
- [x] Route53
- [x] Route53Domains
- [x] S3
- [x] SageMaker
- [x] SES
- [x] ServiceQuotas
- [x] Shield
- [x] SNS
- [x] SQS
- [x] Transfer
- [x] VPC
- [ ] WAF
- [x] WAFv2
- [x] Workspaces
- [x] Xray

### Additional Coverage

One of the primary motivations for AWS Recon was to build a tool that is easy to maintain and extend. If you feel like coverage could be improved for a particular service, we would welcome PRs to that effect. Anyone with a moderate familiarity with Ruby will be able to mimic the pattern used by the existing collectors to query a specific service and add the results to the resource collection.

### Development

Clone this repository:

```
$ git clone git@github.com:darkbitio/aws-recon.git
$ cd aws-recon
```

Create a sticky gemset if using RVM:

```
$ rvm use 2.6.5@aws_recon_dev --create --ruby-version
```

Run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### TODO

- [ ] Optionally suppress AWS API errors instead of re-raising them
- [x] Package as a gem
- [ ] Test coverage with AWS SDK stubbed resources


## Kudos

AWS Recon was inspired by the excellent work of the people and teams behind these tools:

- CloudMapper [https://github.com/duo-labs/cloudmapper](https://github.com/duo-labs/cloudmapper)
- Prowler [https://github.com/toniblyx/prowler](https://github.com/toniblyx/prowler)
- CloudSploit [https://github.com/cloudsploit/scans](https://github.com/cloudsploit/scans)
