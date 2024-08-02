#----------------------------------------
# VPC
#----------------------------------------
resource "aws_vpc" "app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "vpc_app"
  }
}
#----------------------------------------
# インターネットゲートウェイ
#----------------------------------------
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags = {
    Name = "igw_app"
  }
}
#----------------------------------------
# パブリックサブネット
#----------------------------------------
resource "aws_subnet" "pub1" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1a_app"
  }
}

resource "aws_subnet" "pub2" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1c_app"
  }
}
#----------------------------------------
# プライベートサブネット
#----------------------------------------
resource "aws_subnet" "priv" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_1a_app"
  }
}
#----------------------------------------
# ルートテーブル パブリック
#----------------------------------------
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
  tags = {
    Name = "routetable_public_app"
  }
}
#----------------------------------------
# サブネットにルートテーブルを紐づけ パブリック
#----------------------------------------
resource "aws_route_table_association" "rt_assoc_pub1" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.pub.id
}
resource "aws_route_table_association" "rt_assoc_pub2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.pub.id
}
#----------------------------------------
# ルートテーブル プライベート
#----------------------------------------
resource "aws_route_table" "priv" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.ec2_nat.primary_network_interface_id
  }
  tags = {
    Name = "routetable_private_app"
  }
}
#----------------------------------------
# サブネットにルートテーブルを紐づけ プライベート
#----------------------------------------
resource "aws_route_table_association" "rt_assoc_priv" {
  subnet_id      = aws_subnet.priv.id
  route_table_id = aws_route_table.priv.id
}
#----------------------------------------
# CloudFrontのManaged Prefix List 取得
#----------------------------------------
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}
#----------------------------------------
# セキュリティグループ パブリックサブネット for app-alb
#----------------------------------------
resource "aws_security_group" "sg_app_alb" {
  name   = "sg_app_alb"
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "sg_app_alb_app"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_sg_app_alb" {
  security_group_id = aws_security_group.sg_app_alb.id

  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  prefix_list_id   = data.aws_ec2_managed_prefix_list.cloudfront.id
}
resource "aws_vpc_security_group_egress_rule" "allow_http_sg_app_alb" {
  security_group_id = aws_security_group.sg_app_alb.id

  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  referenced_security_group_id = aws_security_group.sg_app_ec2.id
}
#----------------------------------------
# セキュリティグループ パブリックサブネット for nat-ec2
#----------------------------------------
resource "aws_security_group" "sg_nat_ec2" {
  name   = "sg_nat_ec2"
  vpc_id = aws_vpc.app.id
  tags = {
    Name = "sg_nat_ec2_app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_app_sg_nat_ec2" {
  security_group_id = aws_security_group.sg_nat_ec2.id

  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  referenced_security_group_id = aws_security_group.sg_app_ec2.id
}

resource "aws_vpc_security_group_egress_rule" "allow_https_sg_nat_ec2" {
  security_group_id = aws_security_group.sg_nat_ec2.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}
#----------------------------------------
# セキュリティグループ プライベートサブネット for app-ec2
#----------------------------------------
resource "aws_security_group" "sg_app_ec2" {
  name   = "sg_app_ec2"
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "sg_app_ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_sg_app_ec2" {
  security_group_id = aws_security_group.sg_app_ec2.id

  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  referenced_security_group_id = aws_security_group.sg_app_alb.id
}

resource "aws_vpc_security_group_egress_rule" "allow_https_sg_app_ec2" {
  security_group_id = aws_security_group.sg_app_ec2.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}