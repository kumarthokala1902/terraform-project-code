output "aws_instance" {
    description = "this hte ip address of the new instance"
    value = aws_instance.new_instance.public_ip
  
}