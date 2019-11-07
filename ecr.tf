locals {
  common_tags = {}
}

resource "aws_ecr_repository" "ecr" {
  count = length(var.registries)
  name  = var.registries[count.index]["name"]

  image_tag_mutability = var.registries[count.index]["image_tag_mutability"]

  image_scanning_configuration {
    scan_on_push = var.registries[count.index]["scan_on_push"]
  }

  tags = merge(local.common_tags, var.custom_tags)
}

resource "aws_ecr_repository_policy" "ecr" {
  count      = length(var.registries_policies)
  repository = var.registries_policies[count.index]["name"]
  policy     = var.registries_policies[count.index]["policy"]

  depends_on = [
    aws_ecr_repository.ecr,
  ]
}

resource "aws_iam_user" "ecr_user" {
  count = length(var.registries) > 0 ? 1 : 0
  name  = "tf-${var.prefix}-${var.project}-${var.env}-ecr-user"
}

resource "aws_iam_access_key" "ecr_user_key" {
  count = length(var.registries) > 0 ? 1 : 0
  user  = aws_iam_user.ecr_user[0].name
}

resource "aws_iam_policy" "ecr_user" {
  count       = length(var.registries) > 0 ? 1 : 0
  name        = "tf-${var.prefix}-${var.project}-${var.env}-ecr-policy"
  path        = "/"
  description = "ECR ${var.prefix}-${var.project}-${var.env}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Effect": "Allow",
    "Action": [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ],
    "Resource": [
      "arn:aws:ecr:${var.aws["region"]}:${data.aws_caller_identity.current.account_id}:repository/${var.project}/*"
    ]
    },
    {
    "Effect": "Allow",
    "Action": [
      "ecr:GetAuthorizationToken"
    ],
    "Resource": [
      "*"
    ]
    }
  ]
  }
EOF
}

resource "aws_iam_user_policy_attachment" "ecr_user" {
  count      = length(var.registries) > 0 ? 1 : 0
  user       = aws_iam_user.ecr_user[0].name
  policy_arn = aws_iam_policy.ecr_user[0].arn
}

output "ecr_repositories" {
  value = aws_ecr_repository.ecr[*].repository_url
}

output "ecr_user_access_key_id" {
  value = aws_iam_access_key.ecr_user_key.*.id
}

output "ecr_user_secret_access_key" {
  value     = aws_iam_access_key.ecr_user_key.*.secret
  sensitive = true
}
