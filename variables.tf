variable "region" {
  default     = "us-west-2"
  type        = string
  description = "The AWS Region to deploy Ghost"
}


variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}


variable "ghost_url_domain" {
  type = string

}

variable "ghost_ssl_email" {
  type = string

}

variable "ghost_a_record_name" {
  type    = string
  default = "na"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = "false"
  description = "true/false"
}


variable "create_dns_record_existing_domain" {
  type        = bool
  default     = "true"
  description = "true/false"
}

variable "create_ip_only_setup" {
  type        = bool
  default     = "true"
  description = "true/false"
}


variable "ami_id" {
  type        = string
  description = ""
  default     = "NA"
}

variable "env_name" {
  # default     = "us-west-2"
  type        = string
  description = "The environment key to append to resources"
}


variable "instance_type" {
  # default     = "us-west-2"
  type        = string
  description = "The environment key to append to resources"
  default     = "t3.small"
}



variable "zone_id" {
  type = string

}

variable "allowed_cidrs_public_dns" {
  type    = list(any)
  default = []
}

