# WEB+DB PRESS Vol.112 連載「小さなチームでインフラ運用」サンプルコード
技術評論社刊「WEB+DB PRESS Vol.112」の連載「小さなチームでインフラ運用」第2回「コード化によるインフラ管理」のサンプルコードです。

## 内容
Terraform で Amazon VPC とサブネットを作成・管理するというものです。

VPCやサブネットの詳細は vpc.tf を参照してください。

## 環境設定
### AWSアカウントの認証情報
AWSアカウントの認証情報を適宜セットしてください。

#### アクセスキーをそのまま使う場合
以下のようにアクセスキーを `~/.aws/credentials` にセットしてください。

```
[default]
aws_access_key_id     = AKIABAJOSOSIUTARONNEY
aws_secret_access_key = 44K+t44Op44Kt/44Op55y85+YqbCg
region                = ap-northeast-1
```

#### AssumeRoleする場合**
AWSアカウントB (アカウントID: `111111111111`) のIAMロール `ExampleAdminDeveloper` をAssumeRoleする場合、 `~/.aws/credentials` に以下のようにセットしてください。

```
[default]
aws_access_key_id     = AKIABAJOSOSIUTARONNEY
aws_secret_access_key = 44K+t44Op44Kt/44Op55y85+YqbCg
region                = ap-northeast-1

[example-service]
role_arn       = arn:aws:iam::111111111111:role/ExampleAdminDeveloper
region         = ap-northeast-1
source_profile = default
```

AssumeRoleする場合は terraform 実行時に環境変数 `AWS_PROFILE=example-service` をセットしてください。

### terraformのインストール
[tfenv](https://github.com/tfutils/tfenv) を使用したインストール方法を紹介します。

Homebrew で tfenv をインストールします。

```
$ brew install tfenv
```

このリポジトリに移動して以下のコマンドを実行します。
tfenvが [.terraform-version](https://github.com/dozen/webdb112/blob/master/.terraform-version) を読み込んで、 terraform v0.12.1 をインストールしてくれます。

```shell
$ tfenv install
[INFO] Installing Terraform v0.12.1
[INFO] Downloading release tarball from https://releases.hashicorp.com/terraform/0.12.1/terraform_0.12.1_darwin_amd64.zip
######################################################################## 100.0%
[INFO] Downloading SHA hash file from https://releases.hashicorp.com/terraform/0.12.1/terraform_0.12.1_SHA256SUMS
tfenv: tfenv-install: [WARN] No keybase install found, skipping OpenPGP signature verification
Archive:  tfenv_download.YvVaxn/terraform_0.12.1_darwin_amd64.zip
  inflating: /usr/local/Cellar/tfenv/1.0.1/versions/0.12.1/terraform  
[INFO] Installation of terraform v0.12.1 successful
[INFO] Switching to v0.12.1
[INFO] Switching completed
```

### S3バケット・KMSのカスタム管理キー(CMK)の用意
このサンプルでは tfstate を暗号化してS3に保管します。

S3バケットと、KMSのカスタム管理キーを作成しておいてください。

S3バケットを作成する際には `バージョニング` を有効にしておきましょう。

#### とりあえず動かしたい場合
S3バケットとKMSによる暗号化をスキップしてとりあえず動かしたいという場合は [config.tf](https://github.com/dozen/webdb112/blob/master/config.tf) の backend の設定を省略してください。

```diff
diff --git a/config.tf b/config.tf
index 6b836b6..81283ee 100644
--- a/config.tf
+++ b/config.tf
@@ -5,12 +5,4 @@ provider "aws" {
 
 terraform {
   required_version = "= 0.12.1"
-
-  backend "s3" {
-    bucket     = "terraform.example.com" # 作成したS3バケット名で置き換える
-    key        = "terraform.tfstate"
-    region     = "ap-northeast-1"
-    encrypt    = true
-    kms_key_id = "arn:aws:kms:ap-northeast-1:111111111111:key/44757374-2069-6e20-74686-52077696e64" # 発行したCMKで置き換える
-  }
 }
 ```

## 実行方法
環境設定が済んだら、実際に Terraform を実行してみます。

### 設定書き換え
`config.tf` の backend の設定を適宜書き換えておいてください。

S3バケットとKMSのCMKを用意していない場合は backend の記述を消して下さい。
この場合は作業ディレクトリに tfstate が生成されます。

### terraform init
`terraform init` で作業ディレクトリの初期化をします。

```
$ terraform init

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

terraform-provider-aws のインストールなどが実行されました。
`terraform version` でインストールされた provider のバージョンを見ることができます。

```
$ terraform version
Terraform v0.12.1
+ provider.aws v2.14.0
```

### terraform plan
applyする前に `terraform plan` で実行計画を確認しておきます。

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_subnet.myvpc-az-a will be created
  + resource "aws_subnet" "myvpc-az-a" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "ap-northeast-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.1.1.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "myvpc-az-a"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.myvpc will be created
  + resource "aws_vpc" "myvpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.1.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = true
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "myvpc"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### terraform apply
planの結果を確認したら apply してください。

```
$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_subnet.myvpc-az-a will be created
  + resource "aws_subnet" "myvpc-az-a" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "ap-northeast-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.1.1.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block                 = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Name" = "myvpc-az-a"
        }
      + vpc_id                          = (known after apply)
    }

  # aws_vpc.myvpc will be created
  + resource "aws_vpc" "myvpc" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.1.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = true
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Name" = "myvpc"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.myvpc: Creating...
aws_vpc.myvpc: Creation complete after 2s [id=vpc-0123456543210]
aws_subnet.myvpc-az-a: Creating...
aws_subnet.myvpc-az-a: Creation complete after 1s [id=subnet-0123456789]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```