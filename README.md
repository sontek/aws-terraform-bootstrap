# Bootstrap
This is a special workspace that is expected to be ran *locally* and not via a
pull request.  It is only used to setup the bare minimum access necessary for
GitHub + Terraform Cloud to be able to manage the rest.

- Sets up dynamic provider authentication with OIDC
    - https://developer.hashicorp.com/terraform/tutorials/cloud/dynamic-credentials


For first pass you'll have to use the `root` user credentials via:

https://us-east-1.console.aws.amazon.com/iamv2/home#/security_credentials

but after first pass this is *not* recommended. You should utilize the SSO
users after initial bootstrapping is executed.

## Things maintained here
- GitHub Repositories
- Terraform Cloud Workspaces

## Getting Started
To get started with the bootstrap you need to setup your environment. First, you'll need
a GitHub Access Token that has:

- repo: Full Access
- read:org
- read:discussion

Set this as an environment variable `GITHUB_TOKEN`.

Then you need to be logged into terraform cloud.  To do this run:

```
terraform login
```

Then you can run the terraform. 

```bash
terraform plan
terraform apply
```

We do expect that state from the bootstrap is committed to `git` (the .tfstate files).

# Resources
- [Blog on this setup](https://sontek.net/blog/2023/aws_from_scratch_root_account)