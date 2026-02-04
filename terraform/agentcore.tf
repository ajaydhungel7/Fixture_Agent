resource "aws_cloudformation_stack" "agentcore_runtime" {
  name          = "${var.project_name}-agentcore-runtime"
  template_body = file("${path.module}/agentcore-runtime.yaml")
  capabilities  = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    RuntimeName      = var.agentcore_runtime_name
    RoleArn          = aws_iam_role.agentcore_runtime.arn
    ImageUri         = "${aws_ecr_repository.app.repository_url}:latest"
    NetworkMode      = var.agentcore_network_mode
    SubnetIds        = join(",", aws_subnet.public[*].id)
    SecurityGroupIds = aws_security_group.service.id
  }
}

output "agentcore_runtime_arn" {
  value = aws_cloudformation_stack.agentcore_runtime.outputs["AgentRuntimeArn"]
}
