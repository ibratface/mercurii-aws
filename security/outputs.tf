output "codebuild_security_group_id" {
  value = aws_security_group.codebuild.id
}

output "database_security_group_id" {
  value = aws_security_group.db.id
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild.arn
}

output "api_role_arn" {
  value = aws_iam_role.api.arn
}