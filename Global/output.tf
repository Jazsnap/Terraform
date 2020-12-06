
output "ami" {
    value = data.aws_ami.ubuntu.id
}

output "public-subnet" {
    value = aws_subnet.public.id
}

output "public-subnet-2" {
    value = aws_subnet.public-2.id
}

output "private-subnet" {
    value = aws_subnet.private.id
}

output "private-subnet-2" {
    value = aws_subnet.private-2.id
}

output "vpc-id" {
    value = aws_vpc.main.id
}
