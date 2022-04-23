output "key" {
  description = "ssh key"
  value       = tls_private_key.myprvtkey.private_key_pem
  sensitive = true
}

output "id" {
  description = "List of IDs of instances"
  value       = aws_instance.awsvm.*.id
}




output "key_name" {
  description = "List of key names of instances"
  value       = aws_instance.awsvm.*.key_name
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, awsvm is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.awsvm.*.public_dns
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.awsvm.*.public_ip
}

output "private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.awsvm.*.private_dns
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.awsvm.*.private_ip
}

output "security_groups" {
  description = "List of associated security groups of instances"
  value       = aws_instance.awsvm.*.security_groups
}

output "vpc_security_group_ids" {
  description = "List of associated security groups of instances, if running in non-default VPC"
  value       = aws_instance.awsvm.*.vpc_security_group_ids
}

output "subnet_id" {
  description = "List of IDs of VPC subnets of instances"
  value       = aws_instance.awsvm.*.subnet_id
}


