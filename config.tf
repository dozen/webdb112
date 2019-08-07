provider "aws" {
  version = "= 2.14.0"
  region  = "ap-northeast-1"
}

terraform {
  required_version = "= 0.12.1"

  backend "s3" {
    bucket     = "terraform.example.com" # 作成したS3バケット名で置き換える
    key        = "terraform.tfstate"
    region     = "ap-northeast-1"
    encrypt    = true
    kms_key_id = "arn:aws:kms:ap-northeast-1:111111111111:key/44757374-2069-6e20-74686-52077696e64" # 発行したCMKで置き換える
  }
}
