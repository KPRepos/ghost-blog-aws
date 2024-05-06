resource "aws_security_group" "ghost_sg" {
  name        = "ghost-sg"
  description = "Security group for ghost VM"
  vpc_id      = module.vpc.vpc_id
}


resource "aws_security_group_rule" "ghost_ingress_api_server_443" {
  security_group_id = aws_security_group.ghost_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  #   cidr_blocks       = ["${local.public_ip}/32"]
}

resource "aws_security_group_rule" "ghost_ingress_api_server_80" {
  security_group_id = aws_security_group.ghost_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  #   cidr_blocks       = ["${local.public_ip}/32"]
}


resource "aws_security_group_rule" "ghost_egress" {
  security_group_id = aws_security_group.ghost_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
