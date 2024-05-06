### Required
region             = "us-west-2"
env_name           = "Ghost-setup-test"
vpc_cidr           = "10.0.0.0/16"
instance_type      = "t3.small"
enable_nat_gateway = "false"

# Default option to install Ghost using EIP and then manually configure DNS/SSL at later point(More info in README.MD)
create_ip_only_setup = true




### Below will only work if create_ip_only_setup = false, if not R53 record will be ignored and SSL setup will ignor ein userdata logic
### Below variables are required if entire DNS setup want to be automated  - Public Hosted Zone in same AWS Account a PreReq
### (Optional) If DNS record being handled outside R53, this will be false (Need to not deploy ec2 and then update ec2)
create_dns_record_existing_domain = "true"
# if create_dns_record_existing_domain is true, below info is required.
zone_id             = "Z08...." #Public Hosted Zone ID
ghost_a_record_name = "ghost-domain-url.com"

## Below will be passed to Ghost CLI as part of Installation for SSL certs
ghost_url_domain = "https://ghost-domain-url.com"
ghost_ssl_email  = "ghost-domain-url@email.com"


### Ignore for now - Will be updated later, currently deployed blog opens to 0.0.0.0/0 
allowed_cidrs_public_dns = []
ami_id                   = "" # Ubuntu is being retrieved from local.tf ubuntu-jammy-22.04-amd64-server
