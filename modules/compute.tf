data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

// RESOURCE REFERNCING FROM ANOTHER FILE I.E NETWORKING.terraform 
resource "aws_instance" "ec2_instance" {
  count                  = var.instance_count
  ami                    = data.aws_ami.server_ami.id
  instance_type          = var.instance_type
  subnet_id              = element(aws_subnet.N10135_public_subnet.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.N10135_test_sg.id]

  root_block_device {
    volume_size = var.vol_size

  }
}

output "instance_information" {
  value = {
    instance_id = aws_instance.ec2_instance[*].id
    public_ip   = aws_instance.ec2_instance[*].public_ip
  }
}
