variable "aws_region" {
  default = "us-east-1"
}

variable "domain_name" {
  default = "eit-demo.com"
}

variable "enable_gzip" {
  type        = string
  description = "Whether to make CloudFront automatically compress content for web requests that include `Accept-Encoding: gzip` in the request header"
  default     = true
}
