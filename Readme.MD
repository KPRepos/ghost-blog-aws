#### Code -->  https://github.com/KPRepos/ghost-blog-aws
#### End to End setup of Ghost Blog using DNS or Public EIP 

### Supported types
#### E2E in AWS - DNS requires prereq of existing Public Hosted Zone in same AWS Account
#### Partial in AWS  - DNS elsewhere or using IP only method 


### (optional) Update provider-backend.tf with bucket info if need to use s3 for state file
### update variables.auto.tfvars per requirement

`terraform init && terraform apply`

 Once applied, Access Ghost via Public IP of ec2 or DNS based on setup model.(Ex:- http://EIP/ghost/)
#### Default username and pass need to setup for first time - http://EIP/ghost/#/setup

#### If choosen IP approach, Once ready with DNS setup, DNS and SSL  can be updated as below by logging into ec2 

`ghost config url https://ghost-domain-url.com`

`ghost setup nginx`

`ghost restart`


### Ec2 Login - No SSH Keys

 If Session manager plugin installed already, directly login to ec2 from terminal using below command or via UI from Connect-->Session manager

`aws ssm start-session --target $(aws ec2 describe-instances --query "Reservations[*].Instances[?Tags[?Key=='Name'&&Value=='Ghost-New']].InstanceId" --output text --region us-west-2) --region us-west-2`



##### Notes/References:- 
* Ghost needs sudo to update folder contents so sudo password requirement is removed via sudoers file 
* username for blogadmin, mysql saved in secrets manager
* Root Disk is set to 100GB
* Node versions https://ghost.org/docs/faq/node-versions/
* Referance steps  - https://ghost.org/docs/install/ubuntu/
* VPC module from terraform-aws-modules/vpc/aws 

#### Pending
* Mail Setup