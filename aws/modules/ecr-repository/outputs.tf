# ------------------------------------------------------------------------------
# ECR REPOSITORY OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The registry ID"
  value       = aws_ecr_repository.main.registry_id
}

output "arn" {
  description = "The ARN of the repository"
  value       = aws_ecr_repository.main.arn
}

output "name" {
  description = "The name of the repository"
  value       = aws_ecr_repository.main.name
}

output "repository_url" {
  description = "The URL of the repository"
  value       = aws_ecr_repository.main.repository_url
}

output "registry_id" {
  description = "The registry ID where the repository was created"
  value       = aws_ecr_repository.main.registry_id
}

# ------------------------------------------------------------------------------
# HELPER OUTPUTS
# ------------------------------------------------------------------------------

output "image_uri_latest" {
  description = "Repository URL with :latest tag"
  value       = "${aws_ecr_repository.main.repository_url}:latest"
}

output "push_commands" {
  description = "Docker push commands for this repository"
  value = {
    login = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    build = "docker build -t ${aws_ecr_repository.main.name} ."
    tag   = "docker tag ${aws_ecr_repository.main.name}:latest ${aws_ecr_repository.main.repository_url}:latest"
    push  = "docker push ${aws_ecr_repository.main.repository_url}:latest"
  }
}
