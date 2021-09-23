# Contributing

## Contents of this file

### For contributors

- [Build and test locally](#build-and-test-locally)
- [Conventions to follow](#conventions-to-follow)
- [Testing and linting](#testing-and-linting)
- [Updating Changelog](#updating-changelog)

## Build and test locally

### Prerequisites

#### Tools

The testing framework requires the following tools

- [terraform](https://registry.terraform.io/)
- [cinc-auditor](https://cinc.sh/start/auditor/)

#### Test code locations

##### Deployment

The deployment code for testing the assets lives in [examples/](examples/).
Once the code is deployed, a set of tests are run against it to make sure
the platform is functioning as expected

##### Testing

The testing code can all be found in the [test/integration/](test/integration/) folder.
All tests are run by cinc-auditor.

### Build

``` bash
make build
```

### Test

```bash
make test
```

### Clean

``` bash
make clean
```

### All in one

```bash
make all
```

## Conventions to follow

For the test framework
Follow [Terraform Style Conventions](https://www.terraform.io/docs/language/syntax/style.html)
and [Terraform Standard Module Structure](https://www.terraform.io/docs/language/modules/develop/structure.html).

## Updating Changelog

If you open a GitHub pull request on this repo, please update `CHANGELOG` to
reflect your contribution.

Add your entry under `Unreleased`, `Breaking changes`, `New features` or `Fixes`.

Internal changes to the project that are not part of the public API do not need
change log entries, for example fixing the CI build server.

These sections follow [semantic versioning](https://semver.org/), where:

- `Breaking changes` corresponds to a `major` (1.X.X) change.
- `New features` corresponds to a `minor` (X.1.X) change.
- `Fixes` corresponds to a `patch` (X.X.1) change.

See the [`CHANGELOG_TEMPLATE.md`](CHANGELOG_TEMPLATE.md) for an example for how
this looks.

## Releasing a new version

Each merge to `main` branch will create a GitHub release using semver 1.2.3
syntax.
