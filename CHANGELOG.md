# Changelog

## 0.0.6

🔧 Fixes:

- Added examples of session configuration to README file

- Noted areas for improvement

([PR #6](https://github.com/srb3/terraform-helm-kong-gateway/pull/6))


## 0.0.5

🔧 Fixes:

- Added some extra comments about the secrets module

([PR #5](https://github.com/srb3/terraform-helm-kong-gateway/pull/5))


## 0.0.4

🔧 Fixes:

- Cleaned up PR workflow file

- Updated `.gitignore` file to include test attributes file and test log file

- Updated Makefile to accept variables for kube configuration home and minikube home

- Updated the Makefile to Add a call to cat the test log file in the case of
  test failure

- Corrected the test assertion for running Kong pods

- Updated the Inspec metadata file for the Kong Gatway tests, now it specifies it
  only supports Linux platform family

([PR #4](https://github.com/srb3/terraform-helm-kong-gateway/pull/4))

## 0.0.3

🆕 New features:

- Added configuration for metallb to aid testing on minikube

- Updated Makefile to log out more accurate description

([PR #3](https://github.com/srb3/terraform-helm-kong-gateway/pull/3))

## 0.0.2

💥 Breaking changes:

🆕 New features:

- First commit

- Test framework added

- CHANGELOG and CONTRIBUTING added.

- For changes prior to this, refer to [commit history](https://github.com/srb3/terraform-helm-kong-gateway/commits/main)

([PR #2](https://github.com/srb3/terraform-helm-kong-gateway/pull/2))
