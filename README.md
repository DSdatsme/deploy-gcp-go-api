# GCP Go App deploy automation

This repo is about deploying a simple Go App with static files on a highly managed and scalable GCP Infrastructure fully using terraform.

This go app stores visit counter in database and the frontend is hosted on cloud storage.

The GCP services include:

- Virtual Private Cloud
- Google Compute Engine Images
- Managed Instance Groups For
  - Consul
  - Go App
- Cloud Storage
- Cloud CDN
- Cloud SQL (Postgres)
- Cloud LoadBalancer

![System Architecture Diagram](arch_diagram.png?raw=true "Architecture Diagram for Go Application")

This project contains total of 30 Terraform resources and one GCE image through packer

## Assumptions

- Have idea of GCP and terraform.
- Have desired access to deploy resources
- Have ubuntu image in your project
- Have default GCP APIs enabled by default with a fresh project. [link](https://console.developers.google.com/apis/api/)
- Your repo is private. If its public still it will work, but still you will have to specify github token

## About Setup

Giving some brief intro on what some of the important Terraform config file does.

### VPC

> file: `vpc.tf`

- Creating a VPC in custom mode with only one subnet.
- Also creating a service peering connection which is later used by CloudSQL.

### Go App

> file: `managed_instance_group.tf`

- Application VMs are currectly configured to run with public IP, this is done for debugging purpose, that can be removed for production use.
- The precompiled binary in this repo is done for ubuntu18 platform, you may have to compile again if required for your systems. Check below for steps on how to do it.
- Consul agent present on app servers require some specific GCP permission scope to figure out consul servers in the project and join 'em.
- By default only one replica is run, but if the CPU consumption on them increases, they autoscale horizontally.
- If you wish to manually run unmanaged version of API server, you can explore `apiserver.tf` file.

### Consul Server

> file: `consul.tf`

- They are deployed to custom VPC using terraform module.
- Default cluster size is set to two nodes in this repo.
- Currently port 8500 and 22 is exposed to public just for debugging purpose, that can be removed for production.
- App server connect to consul using private IP as they are in same VPC.

### Load Balancer

> file: `loadbalancer.tf`

- LB is created using module and we have attached some url maps for specifc routing for cloud storage and Go App.
- We have also created LB backends for GCE and GCS which are later used by url maps for custom routing.
- URL maps resource also creates cloud CDN.

### CloudSQL

> file: `cloudsql.tf`

- Creating a postgres 12 instance without public IP.
- This instance is peered to our custom VPC and hence app servers can access this database privately.
- After instance is created we are also modifying the default root user's password so that we can pass that to application server automatically.

### Cloud Storage

> file: `storage.tf`

- Create a bucket in required region and make it public.
- Upload requied assets to bucket.

## Setup

The following are the sequential steps to be followed to properly setup the infrastructure for this project

### Prerequisites Setup

- Make sure you login to gcloud. Skip if already done. Sample commands are as below

```bash
gcloud auth login
gcloud config set project <project-id>
```

- Assign your user proper IAM access required for the deployment.
- For github token, you'll need `repo` access which includes following permissions
  - repo:status
  - repo_deployment
  - public_repo
  - repo:invite
  - security_events

### Build Compute Engine Image

We will be using sample packerfile to create consule ubuntu image.
Using this Image we will deploy consul and application servers.

Install packer which will be used to build consul image. [download](https://www.packer.io/downloads)

The following is the step to build GCE image. You will have to pass two variables, **project ID** and **GCP zone**.

```bash
git clone https://github.com/hashicorp/terraform-google-consul
cd terraform-google-consul/examples/consul-image/
packer build -var 'project_id=<gcp-project-id>' -var 'zone=<gcp-zone>' consul.json
```

This build will take around 3m-3m30s.
Note the build output, there you will get **image ID** which got built by packer. Sample output here
> ubuntu-18-image: A disk image was created: consul-ubuntu18-aaaaaa-bbbb-cccc-1111-222222222

[Optional] You can remove the dir(terraform-google-consul) if you want as it won't be required further.

### Setup Environment

- Generate github token with private repo access if your repo is private. And export it as below.
<br> OR <br>
 If you don't want to export as an env variable, durring terraform plan/apply terraform will prompt you to input it
  
```bash
export TF_VAR_github_token=<github token>
```

- Need to install Terraform **v0.14.6**. [link for specific version](https://releases.hashicorp.com/terraform/0.14.6/)

### Update Terraform Variables

This step is for updating `variables.tf` file with proper values.

- fetch GCP project ID and update it to `gcp_default_project_id` variable
- Set the unique GCS bucket name to `bucket_name`.
- Decide on a zone where you would like to deploy resources. The value will be mostly the same as passed during image creation. Update `default_gcp_region` and `default_gcp_zone` accordingly.
- Update the `ubuntu_image_name` and set the value as the name of the GCE image we generated in above step by packer.

### Deploy Infra

```bash
cd terraform
terraform init
terraform apply
```

This full apply will take around 15m-17m.

## Bring Down Infra

Follow the following steps to take down infra.

### Removing MySQL User

Since we are modifying root user, it cannot be deleted by terraform or using any commands. Hence you will have to manually remove it from Terraform state file and comment out the config for terraform resource `google_sql_user`.

Now delete the state for `google_sql_user.root-db-user` by running the following command.

```bash
terraform state rm google_sql_user.root-db-user
```

You can verify the list of states by running

```bash
terraform state list
```

### Destroy Infrastructure

Final step is to run terraform command and destroy infrastructure

```bash
terraform destroy
```

Destroy infra takes around 5m.

## Setup Issuess [FAQs]

- if facing auth errors while running terraform plan

```bash
gcloud auth application-default login
```

- if you want to run and check using gcloud commands

```bash
gcloud auth login
```

- build go binary manually

```bash
wget https://golang.org/dl/go1.16.4.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go build deploy-gcp-go-api/api/bin/
```

- if you want to test SQL connection manually. Install postgres client

```bash
sudo apt-get install postgresql-client
```

## Improvements Required

- Implement a backend to store terraform state file.
- Monitoring and alerting setup.
- CloudDNS setup.
- Remove hardcoded values whereever possible.
- And many more...
