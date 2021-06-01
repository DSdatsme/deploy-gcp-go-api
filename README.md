
# GCP GO App deploy automation

## Assumptions

- Have desired access to deploy resources
- Have ubuntu image in your project
- Enable Service Networking API [link](https://console.developers.google.com/apis/api/servicenetworking.googleapis.com/overview?)
- Your repo is private. If its public still it will work, but still you will have to specify github token

## Setup

### Setup Variables

- fetch GCP project ID and update it to `gcp_default_project_id` variable
- Set the unique GCS bucket name.

## build image

git clone https://github.com/hashicorp/terraform-google-consul
cd terraform-google-consul/examples/consul-image/
packer build -var 'project_id=playground-s-11-d7d433da' -var 'zone=asia-south1-b' consul.json


### Setup Environment

- Generate github token with private repo access if your repo is private. And export it as below.
<br> OR <br>
 If you don't want to export as an env variable, durring terraform plan/apply terraform will prompt you to input it
  
```bash
export TF_VAR_github_token=<github token>
```

- Need to install Terraform **v0.14.6**. [link for specific version](https://releases.hashicorp.com/terraform/0.14.6/)

### Deploy

```bash
terraform init
terraform plan
```

## Setup Issuess

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

- Implement a backend to store state file.
