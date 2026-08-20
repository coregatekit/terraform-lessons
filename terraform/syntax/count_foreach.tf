resource "aws_s3_bucket" "logs" {
  count  = 3
  bucket = "my-app-logs-${count.index}" # count.index = 0, 1, 2
}

resource "aws_s3_bucket" "logs_foreach" {
  for_each = toset(["dev", "staging", "prod"])
  bucket   = "my-app-logs-${each.key}" # each.key = each.value = dev, staging, prod
}

##### Example
variable "regions" {
  default = ["ap-southeast-1", "us-east-1", "eu-west-1"]
}

resource "aws_instance" "app" {
  count = length(var.regions)
  ami = "ami-12345"
  instance_type = "t3.micro"
  # provider = aws.${var.regions[count.index]} (สมมติมี provider alias ต่อ region)
  tags = {
    Name = "app-${count.index}"
  }
}

##### Solve
resource "aws_instance" "app_foreach" {
  for_each = toset(var.regions)
  ami = "ami-12345"
  instance_type = "t3.micro"
  tags = {
    Name = "app-${each.key}"
  }
}
