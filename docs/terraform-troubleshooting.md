# Terraform Troubleshooting

## Apple Silicon Terraform Timeout

On this machine, `tfenv` was using Terraform `v1.4.0` for `darwin_amd64` while the Mac itself is `arm64`. That mismatch can make large providers, especially the AWS provider, hang or timeout during `terraform init` or `terraform validate`.

Use an arm64 Terraform binary:

```bash
export TFENV_ARCH=arm64
tfenv install
tfenv use
terraform version
```

Expected result should show an `arm64` Terraform build and the version from `.terraform-version`.

## Validation Commands

Run:

```bash
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
```

For a real AWS plan:

```bash
terraform -chdir=terraform plan \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1
```

## Notes

- `terraform init` needs internet access to download providers and modules.
- `terraform validate` should not need AWS credentials after init completes.
- `terraform plan` needs AWS credentials because it reads AWS account and region data.

