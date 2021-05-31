
# GCP GO App deploy automation

## Assumptions

- Default VPC is setup
- Have desired access to deploy resources
- Have hardcoded images in your project
- Enable Service Networking API 


## Setup

### setup environment

```bash
export TF_VAR_github_token=<github token>
```

### API Server

test connect to postgress

```bash
sudo apt-get install postgresql-client

```




## Setup Issuess

- if facing auth errors while running terraform plan

```bash
gcloud auth application-default login
```
