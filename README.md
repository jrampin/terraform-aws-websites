# Terraform - Website

This is a Terraform code designed to automate the deployment of a static website.

This code creates the following resources:

- two ACM certificates:
    * one for the www domain (www.eit-demo.com)
    * one for the naked domain (eit-demo.com) 

- two S3 buckets:
    * one for the content ("www.eit-demo.com")
    * one for redirecting from the naked domain to www (named "eit-demo.com")

- two CloudFront distribution, one per bucket, that also redirect from HTTP to HTTPS
- two Route53 alias records, one per CloudFront distribution

### Architecture

Here's a neat mindmap designed with CloudCraft for what Terraform will build

![Architecture](images/architecture.png)