# gcp-terraform

## require

- terraform
- gcloud

※[You need to attach `servicenetworking.networksAdmin` role to terraform execute service account for private vpc connection](https://github.com/hashicorp/terraform-provider-google/issues/4066#issuecomment-513650386)

```shell
# @see https://cloud.google.com/sdk/gcloud/reference/projects/add-iam-policy-binding
$ gcloud projects add-iam-policy-binding {{project_id}} \
--member='serviceAccount:{{member}}' \
--role='roles/servicenetworking.networksAdmin'
```

---
## setup

- set server account credential file path to `~/.zshrc` 

```shell
# this value use for terraform
# @see https://www.terraform.io/docs/language/settings/backends/gcs.html#configuration-variables
export GOOGLE_CREDENTIALS="~/terraform-sandbox.json"
```

---
## run

- create infra by terraform

```shell
terraform init

terraform apply
```

---
## after apply

- confirm creation 

```shell
# check instance name and public ip
gcloud compute instances list

# check db instance name and private ip
gcloud sql instances list
```

- set postgres user password

```shell
gcloud sql users set-password postgres \
--instance=INSTANCE_NAME \
--prompt-for-password
```

- connect to compute engine instance

```shell
gcloud compute ssh instance-1
```

- create db via instance

```shell
t.kiyota@instance-1:~$ psql -h {{sql_instance_private_ip}} -U postgres

postgres=> create database employee;
CREATE DATABASE

postgres=> \l
postgres=> \q
```

- sample program clone

```shell
git clone https://github.com/KiyotaTakeshi/gcp-backend-sample

cd gcp-backend-sample
```

- override db connection info using environment variable

```shell
export SPRING_DATASOURCE_URL=jdbc:postgresql://{{sql_instance_private_ip}}:5432/employee
# ex.) export SPRING_DATASOURCE_URL=jdbc:postgresql://10.46.192.3:5432/employee

export SPRING_DATASOURCE_USERNAME=postgres

export SPRING_DATASOURCE_PASSWORD={{password}}
# ex.) export SPRING_DATASOURCE_PASSWORD=ded1fccd-4df9-4825-83f7-19bc7b9ad843
```

- run

```shell
./gradlew bootRun
```

---
## test api

```shell
# check instance public ip
gcloud compute instances list

curl http://{{compute_engine_public_ip}}:8081/employees
# curl http://35.194.97.21:8081/employees -s | jq .
```


---
# TODO: 

## deploy to Cloud Run

