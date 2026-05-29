# Image système Ubuntu 22.04 la plus récente
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "${var.project_name}-key-${data.aws_caller_identity.current.account_id}"
  public_key = tls_private_key.ec2.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ec2.private_key_pem
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400"
}

# Machine pour Nginx (Ansible s'en occupe après)
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type # t3.micro
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.ec2.key_name

  root_block_device {
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-web"
  }
}
