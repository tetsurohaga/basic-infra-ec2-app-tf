#----------------------------------------
# EC2インスタンス ec2-app
#----------------------------------------
resource "aws_instance" "ec2_app" {
  ami = "{{ AMI_ID }}"
  associate_public_ip_address = false
  availability_zone = "ap-northeast-1a"
  iam_instance_profile = "{{ IAM_ROLE_NAME }}"
  instance_market_options {
    market_type = "spot"
  }
  instance_type = "t2.micro"
  metadata_options {
    http_tokens = "optional"
  }
  subnet_id = aws_subnet.priv.id
  vpc_security_group_ids = [aws_security_group.sg_app_ec2.id]
  tags = {
    Name = "ec2_app"
  }
}
#----------------------------------------
# NATインスタンス ec2-app
#----------------------------------------
resource "aws_instance" "ec2_nat" {
  ami = "{{ AMI_ID }}"
  associate_public_ip_address = true
  availability_zone = "ap-northeast-1a"
  iam_instance_profile = "{{ IAM_ROLE_NAME }}"
  instance_market_options {
    market_type = "spot"
  }
  instance_type = "t2.micro"
  metadata_options {
    http_tokens = "optional"
  }
  subnet_id = aws_subnet.pub1.id
  source_dest_check = false
  vpc_security_group_ids = [aws_security_group.sg_nat_ec2.id]
  tags = {
    Name = "ec2_nat"
  }
}
