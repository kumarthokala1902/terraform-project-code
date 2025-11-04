output "instance_id" {
  value = aws_instance.olake_vm.id
}
output "vm_public_ip" {
  value = aws_instance.olake_vm.public_ip
}
