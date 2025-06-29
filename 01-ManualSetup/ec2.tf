resource "aws_instance" "workstation" {
  ami           = "ami-09c813fb71547fc4f"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-08ddaa8cfe73d4af2"]


  tags = {
    Name = "work-station"
    envionment = "test"
  }
}

output "public_ip_for_workstation" {
  value = aws_instance.workstation.public_ip
}