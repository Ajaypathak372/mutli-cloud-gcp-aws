# mutli-cloud-gcp-aws
This repository contains all the terraform modules to set up a Multi - Cloud Infrastructure using Terraform.

After pulling this repository do the following steps

First chnage the account name and put your credentials in the main.tf file.
Then run these following commands

1. To initialise and download all the required terraform plugins for all the providers :- 
        terraform init
2. Check sytnax error :- 
        terraform validate
3. To create all the resources :-
        terraform apply
              or
   terraform apply --auto-approve
