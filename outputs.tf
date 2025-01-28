output "instance_ami" {
  value = aws_instance.blog.ami
}

output "instance_arn" {
  value = aws_instance.blog.arn
}

output "instance_dns" {
  value = aws_instance.blog.public_dns
}

output "instance_ip" {
  value = aws_instance.blog.public_ip
}