
# https://github.com/KPRepos/ghost-blog-aws

resource "aws_iam_role" "ghost-ec2-role" {
  name               = "ghost-ec2-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "ghost_iam_role_policy" {
  name   = "ghost_iam_role_policy"
  role   = aws_iam_role.ghost-ec2-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["secretsmanager:PutSecretValue","secretsmanager:UpdateSecret"],
      "Resource": "${aws_secretsmanager_secret.blogadmin_password.arn}"
    },
    {
      "Effect": "Allow",
      "Action": ["secretsmanager:PutSecretValue","secretsmanager:UpdateSecret"],
      "Resource": "${aws_secretsmanager_secret.mysql_password.arn}"
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "ghost-ec2-role" {
  name = "ghost-ec2-iam-role-profile"
  role = aws_iam_role.ghost-ec2-role.name
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.ghost-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_route53_record" "ghost_a_record" {
  count   = var.create_ip_only_setup == false && var.create_dns_record_existing_domain ? 1 : 0
  zone_id = var.zone_id
  name    = var.ghost_a_record_name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.ghost-public-ip.public_ip]
}



# #Creating a AWS secret 

resource "aws_secretsmanager_secret" "blogadmin_password" {
  name                    = "blogadmin_password"
  description             = "blogadmin_password"
  recovery_window_in_days = 0
  # Use a lifecycle block to recreate the secret before it's destroyed
  # lifecycle {
  #   create_before_destroy = true
  # }
}


resource "aws_secretsmanager_secret" "mysql_password" {
  name                    = "mysql_password"
  description             = "mysql_password"
  recovery_window_in_days = 0
  # Use a lifecycle block to recreate the secret before it's destroyed
  # lifecycle {
  #   create_before_destroy = true
  # }
}


data "template_file" "user_data_ct" {
  template = file("ghost-userdata.tpl")
  vars = {
    ghost_url_domain     = var.ghost_url_domain
    ghost_ssl_email      = var.ghost_ssl_email
    create_ip_only_setup = var.create_ip_only_setup
  }
}

resource "aws_instance" "ghost" {
  ami = data.aws_ami.ubuntu.image_id

  instance_type               = var.instance_type
  user_data                   = data.template_file.user_data_ct.rendered
  iam_instance_profile        = aws_iam_instance_profile.ghost-ec2-role.name
  vpc_security_group_ids      = [aws_security_group.ghost_sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = false
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp2" # General Purpose SSD
    volume_size           = 50    # Size of the volume in gigabytes
    delete_on_termination = true  # Whether the volume should be deleted on instance termination
  }
  tags = {
    "Name" = "Ghost-New",
  }

}


resource "aws_eip" "ghost-public-ip" {
  instance = aws_instance.ghost.id

  tags = {
    Name = "Ghost-PublicIp"
  }
}

