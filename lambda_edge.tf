data "archive_file" "folder_index_redirect_zip" {
  type        = "zip"
  output_path = "folder_index_redirect.js.zip"
  source_file = "folder_index_redirect.js"
}

resource "aws_iam_role_policy" "lambda_execution" {
  name_prefix = "terraform-lambda-execution-policy-"
  role        = aws_iam_role.lambda_execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_execution" {
  name_prefix        = "terraform-lambda-execution-role-"
  description        = "Managed by Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "folder_index_redirect" {
  description      = "Managed by Terraform"
  filename         = "folder_index_redirect.js.zip"
  function_name    = "CloudFrontIndexHandler-Test"
  handler          = "folder_index_redirect.handler"
  source_code_hash = data.archive_file.folder_index_redirect_zip.output_base64sha256
  provider         = aws.acm
  publish          = true
  role             = aws_iam_role.lambda_execution.arn
  runtime          = "nodejs12.x"

}