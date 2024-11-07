resource "aws_instance" "ec2_example" {
    ami = data.aws_ami.linux.id
    instance_type = var.instance_type 
    subnet_id= aws_subnet.public_subnet.id
    key_name= "ganga"
    vpc_security_group_ids = [aws_security_group.main.id]
    iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name
    availability_zone      = "${data.aws_region.current.name}a"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      password    = ""
      host        = self.public_ip
      private_key = file("C:/Users/Siri/.ssh/id_rsa")
   }

  provisioner "file" {
    source      = "setup_script.sh"
    destination = "/tmp/setup_script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_script.sh",
      "bash /tmp/setup_script.sh "
    ]
  }
  depends_on = [aws_route.public_internet_access]
}

resource "aws_vpc" "main1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc" })
  )
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main1.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a" 
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main1.id
  cidr_block        = "10.0.1.0/24"  
  availability_zone = "ap-south-1a"  
}

resource "aws_security_group" "main" {
  description = "allow ssh to ec2"
  name        = "${local.prefix}-ssh_bastion"
  vpc_id      = aws_vpc.main1.id
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main1.id
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-gateway" })
  )
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main1.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main1.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private" })
  )
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
# resource "aws_key_pair" "deployer" {
#   key_name   = "ganga"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVVYJYznaK1tRES1I9VZ+aDVjly2AYqa9VihRz4jLmqtqMETjXikLMq9bMy48UsrKjYGl/1gugUzqg/hTs0RF7obgBXaKRuEmBl4LsKCc+6RsYFHrGR8PSultehtrEgbuXZ+ug68/XXNc5HN4Ih5d+WV/At2J+bWCgdoKKZKgGhOluZKSiEBFeQD51A2BNqsKeY2QnAqoIv/5xhV0gHF5tS+qQd0VYM73oUqnwpp2Bk6Ew5YZ9w8PIGzu2ju0ibZkKEVWRAspX//Ek6qpNwAMyew5Os5Aa0HWGlE91XBgS90y6iPypJ4VoJDXhJrw2TuFJIEdvbHojVhUbeGmTkAoj Siri@SiriTeju"
# }