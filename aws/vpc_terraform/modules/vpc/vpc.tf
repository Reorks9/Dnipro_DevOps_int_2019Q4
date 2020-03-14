#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create VPC
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_vpc" "vpc" {
    cidr_block                          = var.vpc_cidr
    instance_tenancy                    = var.instance_tenancy
    enable_dns_support                  = var.enable_dns_support
    enable_dns_hostnames                = var.enable_dns_hostnames
    assign_generated_ipv6_cidr_block    = var.assign_generated_ipv6_cidr_block
    enable_classiclink                  = var.enable_classiclink

    tags = {
        Name            = "${lower(var.name)}-vpc-${lower(var.environment)}"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add AWS subnets (public)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~
# private
#~~~~~~~~~~~~~~~~~~~
resource "aws_subnet" "private_subnets" {
    count                   = length(var.private_subnet_cidrs)

    cidr_block              = element(var.private_subnet_cidrs, count.index)
    vpc_id                  = aws_vpc.vpc.id
    map_public_ip_on_launch = "false"
    ## need second counter (for create all subnets in each az)
    # count                   = length(var.availability_zones)
    # availability_zone       = element(var.availability_zones, count.index)
    availability_zone       = element(var.availability_zones, 0)
    
    tags = {
        Name            = "private_subnet-${element(var.availability_zones, count.index)}"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }

    depends_on        = [aws_vpc.vpc]
}

#~~~~~~~~~~~~~~~~~~~
# public
#~~~~~~~~~~~~~~~~~~~
resource "aws_subnet" "public_subnets" {
    count                   = length(var.public_subnet_cidrs)

    cidr_block              = element(var.public_subnet_cidrs, count.index)
    vpc_id                  = aws_vpc.vpc.id
    map_public_ip_on_launch = var.map_public_ip_on_launch
    availability_zone       = element(var.availability_zones, 0)
    
    tags = {
        Name            = "public_subnet-${element(var.availability_zones, count.index)}"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }

    depends_on        = [aws_vpc.vpc]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create new security group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_security_group" "sg" {
    name                = "${var.name}-sg-${var.environment}"
    description         = "Security Group ${var.name}-sg-${var.environment}"
    vpc_id              = aws_vpc.vpc.id
    
    tags = {
        Name            = "${var.name}-sg-${var.environment}"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }
    lifecycle {
        create_before_destroy = true
    }
    
    depends_on  = [aws_vpc.vpc]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add default security group rules
# for use default sg change security_group_id to aws_vpc.vpc.default_security_group_id
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~
# ingress
#~~~~~~~~~~~~~~~~~~~
resource "aws_security_group_rule" "ingress_ports" {
    count               = length(var.allowed_ports)

    type                = "ingress"
    security_group_id   = aws_security_group.sg.id
    from_port           = element(var.allowed_ports, count.index)
    to_port             = element(var.allowed_ports, count.index)
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]

    depends_on          = [aws_vpc.vpc]
}

resource "aws_security_group_rule" "icmp-self" {
    type                = "ingress"
    security_group_id   = aws_security_group.sg.id
    protocol            = "icmp"
    from_port           = -1
    to_port             = -1
    self                = true
    
    depends_on          = [aws_vpc.vpc]
}

#~~~~~~~~~~~~~~~~~~~
# egress
#~~~~~~~~~~~~~~~~~~~
resource "aws_security_group_rule" "egress_ports" {
    count               = var.enable_all_egress_ports ? 0 : length(var.allowed_ports)

    type                = "egress"
    security_group_id   = aws_security_group.sg.id
    from_port           = element(var.allowed_ports, count.index)
    to_port             = element(var.allowed_ports, count.index)
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]

    depends_on          = [aws_vpc.vpc]
}

resource "aws_security_group_rule" "default_egress" {
    count             = var.enable_all_egress_ports ? 1 : 0
    
    type              = "egress"
    security_group_id = aws_security_group.sg.id
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    
    depends_on        = [aws_vpc.vpc]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add acl rules (to default vpc nacl)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_default_network_acl" "default_acl" {
    default_network_acl_id = aws_vpc.vpc.default_network_acl_id

    tags = {
        Name            = "${var.name}-nacl-${var.environment}"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }

    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    ingress {
        protocol = "tcp"
        rule_no = 101
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    ingress {
        protocol = "tcp"
        rule_no = 102
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 22
        to_port = 22
    }

    ingress {
        protocol = "tcp"
        rule_no = 103
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 32768
        to_port = 61000
    }

    egress {
        protocol = "all"
        rule_no = 100
        action = "allow"
        cidr_block = aws_vpc.vpc.cidr_block
        from_port = 0
        to_port = 0
    }

    egress {
        protocol = "tcp"
        rule_no = 101
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    egress {
        protocol = "tcp"
        rule_no = 102
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    egress {
        protocol = "tcp"
        rule_no = 103
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 1024
        to_port = 65535
    }

    depends_on  = [aws_vpc.vpc]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add AWS internet gateway
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_internet_gateway" "internet_gw" {
    count = length(var.public_subnet_cidrs) > 0 ? 1 : 0
    
    vpc_id = aws_vpc.vpc.id
    
    tags = {
        Name            = "internet-gateway to ${var.name}-vpc-${var.environment}"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }
    
    depends_on        = [aws_vpc.vpc]
}

resource "aws_route_table" "public_route_tables" {
    count = length(var.public_subnet_cidrs) > 0 ? 1 : 0
    
    vpc_id           = aws_vpc.vpc.id

    propagating_vgws = var.public_propagating_vgws
    
    tags = {
        Name            = "public_route_tables"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }
    
    depends_on        = [aws_vpc.vpc]
}

resource "aws_route" "public_internet_gateway" {
    count = length(var.public_subnet_cidrs) > 0 ? 1 : 0
    
    route_table_id         = aws_route_table.public_route_tables[0].id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.internet_gw[0].id
    
    depends_on        = [aws_internet_gateway.internet_gw, aws_route_table.public_route_tables]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE EIP
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_eip" "nat_eip" {
    count       = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
    
    vpc         = true
    
    depends_on  = [aws_internet_gateway.internet_gw]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE NAT
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_nat_gateway" "nat_gw" {
    count           = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
    
    allocation_id   = element(aws_eip.nat_eip.*.id, (var.single_nat_gateway ? 0 : count.index))
    subnet_id       = element(aws_subnet.public_subnets.*.id, (var.single_nat_gateway ? 0 : count.index))
    
    depends_on      = [aws_internet_gateway.internet_gw, aws_subnet.public_subnets]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create private route table and the route to the internet
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_route_table" "private_route_tables" {
    count               = length(var.availability_zones)
    
    vpc_id              = aws_vpc.vpc.id
    propagating_vgws    = var.private_propagating_vgws
    
    tags = {
        Name            = "private_route_tables"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }
    
    depends_on          = [aws_vpc.vpc]
}

resource "aws_route" "private_nat_gateway" {
    count                   = var.enable_nat_gateway ? length(var.availability_zones) : 0
    
    route_table_id          = element(aws_route_table.private_route_tables.*.id, count.index)
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = element(aws_nat_gateway.nat_gw.*.id, count.index)
    
    depends_on              = [aws_nat_gateway.nat_gw, aws_route_table.private_route_tables]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE VPN
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~
# VPN Gateway
#~~~~~~~~~~~~~~~~~~~
resource "aws_vpn_gateway" "vpn_gw" {
    count   = var.enable_vpn_gateway ? 1 : 0
    
    vpc_id  = aws_vpc.vpc.id
    
    tags = {
        Name            = "vpn_gateway"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }
    
    depends_on          = [aws_vpc.vpc]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE DHCP
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
    count                = var.enable_dhcp_options ? 1 : 0

    domain_name          = var.dhcp_options_domain_name
    domain_name_servers  = var.dhcp_options_domain_name_servers
    ntp_servers          = var.dhcp_options_ntp_servers
    netbios_name_servers = var.dhcp_options_netbios_name_servers
    netbios_node_type    = var.dhcp_options_netbios_node_type
    
    tags = {
        Name            = "dhcp"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Route Table Associations
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~
# private
#~~~~~~~~~~~~~~~~~~~
resource "aws_route_table_association" "private_route_table_associations" {
    count           = length(var.private_subnet_cidrs)
    
    subnet_id       = element(aws_subnet.private_subnets.*.id, count.index)
    route_table_id  = element(aws_route_table.private_route_tables.*.id, count.index)
    
    depends_on      = [aws_route_table.private_route_tables, aws_subnet.private_subnets]
}

#~~~~~~~~~~~~~~~~~~~
# public
#~~~~~~~~~~~~~~~~~~~
resource "aws_route_table_association" "public_route_table_associations" {
    count           = length(var.public_subnet_cidrs)
    subnet_id       = element(aws_subnet.public_subnets.*.id, count.index)

    route_table_id  = aws_route_table.public_route_tables[0].id
    
    depends_on      = [aws_route_table.public_route_tables, aws_subnet.public_subnets]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DHCP Options Set Association
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options_association" {
    count           = var.enable_dhcp_options ? 1 : 0
    
    vpc_id          = aws_vpc.vpc.id
    dhcp_options_id = aws_vpc_dhcp_options.vpc_dhcp_options[0].id
    
    depends_on      = [aws_vpc.vpc, aws_vpc_dhcp_options.vpc_dhcp_options]
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add AWS ec2
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

data "template_file" "user_data" {
  template = file("${path.module}/init.tpl")
}

#~~~~~~~~~~~~~~~~~~~
# public
#~~~~~~~~~~~~~~~~~~~
resource "aws_instance" "pubec2" {
    count                   = length(var.public_subnet_cidrs)

    ami                     = "ami-0b418580298265d5c" # eu-central-1
    instance_type           = "t2.micro"
    availability_zone       = element(var.availability_zones, count.index)
    vpc_security_group_ids  = [aws_security_group.sg.id]
    subnet_id               = element(aws_subnet.public_subnets.*.id, count.index)
    key_name                = "test_key_for_terraform"
    root_block_device { 
        volume_type         = "gp2"
        volume_size         = 8
        iops                = 100
    }
    user_data               = data.template_file.user_data.rendered

    credit_specification {
        cpu_credits     = "standard"
    }

    tags = {
        Name            = "public_ec2-${element(var.availability_zones, count.index)}"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }

    depends_on          = [aws_route_table_association.public_route_table_associations]
}

#~~~~~~~~~~~~~~~~~~~
# private
#~~~~~~~~~~~~~~~~~~~
resource "aws_instance" "priec2" {
    count                   = length(var.private_subnet_cidrs)

    ami                     = "ami-0b418580298265d5c" # eu-central-1
    instance_type           = "t2.micro"
    availability_zone       = element(var.availability_zones, count.index)
    vpc_security_group_ids  = [aws_security_group.sg.id]
    subnet_id               = element(aws_subnet.private_subnets.*.id, count.index)
    key_name                = "test_key_for_terraform"
    root_block_device { 
        volume_type         = "gp2"
        volume_size         = 8
        iops                = 100
    }
    user_data               = data.template_file.user_data.rendered

    credit_specification {
        cpu_credits     = "standard"
    }

    tags = {
        Name            = "private_ec2-${element(var.availability_zones, count.index)}"
        Environment     = var.environment
        Orchestration   = var.orchestration
        Createdby       = var.createdby
    }

    depends_on          = [aws_route_table_association.private_route_table_associations]
}