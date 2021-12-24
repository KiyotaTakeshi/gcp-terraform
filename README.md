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
## after apply(setup DB)

- confirm creation 

```shell
# check instance name and public ip
gcloud compute instances list

# check db instance name and private ip
gcloud sql instances list

$ gcloud compute networks vpc-access connectors describe test --region asia-northeast1 | grep name
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

---
## deploy to compute engine

※ you also choose to deploy Cloud Run following procedure

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
## deploy to Cloud Run

- if you push image in advance

```shell
$ gcloud auth configure-docker

$ docker tag docker.io/kiyotakeshi/employee:0.0.1 gcr.io/sandbox-330309/employee

$ docker push gcr.io/sandbox-330309/employee
```

- deploy

```shell
gcloud run deploy employee-service \
--memory=1024Mi \
--image=gcr.io/sandbox-330309/employee:latest \
--platform managed \
--port 80 \
--region asia-northeast1 \
--allow-unauthenticated \
--set-env-vars "SERVER_PORT=80,SPRING_DATASOURCE_URL=jdbc:postgresql://{{sql_instance_private_ip}}:5432/employee,SPRING_DATASOURCE_USERNAME=postgres, SPRING_DATASOURCE_PASSWORD=72e759b0-7f57-4481-9c33-7e5fcd2e58e1" \
--vpc-connector test
```

or deploy in source code directory

```shell
$ gcloud run deploy employee-service \
--memory=1024Mi \
--platform managed \
--port 80 \
--region asia-northeast1 \
--allow-unauthenticated \
--set-env-vars "SERVER_PORT=80,SPRING_DATASOURCE_URL=jdbc:postgresql://10.69.96.5:5432/employee,SPRING_DATASOURCE_USERNAME=postgres, SPRING_DATASOURCE_PASSWORD=72e759b0-7f57-4481-9c33-7e5fcd2e58e1" \
--vpc-connector test \
--source .
```

- confirm

```shell
$ gcloud run services list
   SERVICE           REGION           URL                                               LAST DEPLOYED BY              LAST DEPLOYED AT
✔  employee-service  asia-northeast1  https://employee-service-vbiywy34nq-an.a.run.app  test@gmail.com  2021-12-24T05:56:19.620031Z
```

- delete

```shell
$ gcloud run services delete employee-service --region asia-northeast1

$ gcloud compute networks vpc-access connectors delete test --region asia-northeast1-a

$ terraform destroy
```

---
## test api

```shell
# check instance public ip
gcloud compute instances list

curl http://{{compute_engine_public_ip}}:8081/employees
# curl http://35.194.97.21:8081/employees -s | jq .
```
