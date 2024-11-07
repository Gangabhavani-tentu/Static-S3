# Private ec2
resource "aws_instance" "private" {
  ami                    = data.aws_ami.linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name
  availability_zone      = "${data.aws_region.current.name}a"
  vpc_security_group_ids = [aws_security_group.main.id, ]
  key_name               = "ganga"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y awscli
              EOF

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-ec2" })
  )
}


# VPC gateway endpoint
resource "aws_vpc_endpoint" "vpc_gateway_endpoint" {
  vpc_id              = aws_vpc.main1.id
  service_name        = "com.amazonaws.ap-south-1.s3" # com.amazonaws.<region>.<service>
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = [aws_route_table.private.id]
}