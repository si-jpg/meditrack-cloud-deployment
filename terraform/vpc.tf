# Le VPC dans lequel on place l'EC2
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # toutes les IPs possibles du VPC
  enable_dns_hostnames = true          # l'EC2 aura un hostname public
}

# Passerelle pour sortir vers Internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # rattachée au VPC ci-dessus
}

# Un morceau du VPC dédié à l'EC2 (subnet = sous-réseau)
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24" # partie du 10.0.0.0/16, 256 adresses

  map_public_ip_on_launch = true # IP publique auto à chaque démarrage EC2
}

# Où router le trafic qui quitte le subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                  # tout ce qui n'est pas dans le VPC
    gateway_id = aws_internet_gateway.main.id # part vers Internet
  }
}

# Applique la table de routes au subnet public
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Pare-feu de l'EC2 : ports ouverts en entrée
resource "aws_security_group" "web" {
  name   = "${var.project_name}-web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP depuis n'importe où
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTPS
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr] # SSH, plage réglable
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # tous protocoles
    cidr_blocks = ["0.0.0.0/0"] # sortie libre (apt, etc.)
  }
}
