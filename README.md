# AWS Lambda Go Orb

[![CircleCI Build Status](https://circleci.com/gh/10xLabs/aws-lambda-go-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/10xLabs/aws-lambda-go-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/nexbus/aws-lambda-go)](https://circleci.com/orbs/registry/orb/nexbus/aws-lambda-go) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/10xLabs/aws-lambda-go-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)



CircleCI orb for building, testing, linting and deploying Go-based AWS Lambda functions.

## Upgrading to 4.0.0

4.0.0 drops the hand-built `nexbus/go-pulumi` image and runs every job on CircleCI convenience images instead, installing only the tools those images do not carry. Two changes need action in consumer repositories.

**1. golangci-lint 1.58 to 2.12 (breaking).** The Go convenience image ships golangci-lint 2.12.x, whose configuration schema changed. A v1 configuration fails with:

```
can't load config: unsupported version of the configuration: ""
```

Add a version key to `.golangci.yml` and migrate any renamed settings per the [golangci-lint migration guide](https://golangci-lint.run/docs/product/migration-guide):

```yaml
version: "2"
```

**2. Go 1.22 to 1.26.** The `golang` executor now defaults to `cimg/go:1.26`. Pin a different minor if a project is not ready:

```yaml
jobs:
  - aws-lambda-go/test:
      executor:
        name: aws-lambda-go/golang
        tag: "1.25"
```

Also of note: `GOEXPERIMENT=nocoverageredesign` has been removed from the coverage check, because that experiment no longer exists in Go 1.24 and later and made `go` exit with `unknown GOEXPERIMENT coverageredesign`. The `go-pulumi-lint-gh` executor is gone; jobs now use `golang`, `node` or `base`.

Additional READMEs are available in each directory.



## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/nexbus/aws-lambda-go-orb) - The official registry page of this orb for all versions, executors, commands, and jobs described.
[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using and creating CircleCI Orbs.

### How to Contribute

We welcome [issues](https://github.com/10xLabs/aws-lambda-go-orb/issues) to and [pull requests](https://github.com/10xLabs/aws-lambda-go-orb/pulls) against this repository!

### How to Publish
* Create and push a branch with your new features.
* When ready to publish a new production version, create a Pull Request from _feature branch_ to `master`.
* The title of the pull request must contain a special semver tag: `[semver:<segement>]` where `<segment>` is replaced by one of the following values.

| Increment | Description|
| ----------| -----------|
| major     | Issue a 1.0.0 incremented release|
| minor     | Issue a x.1.0 incremented release|
| patch     | Issue a x.x.1 incremented release|
| skip      | Do not issue a release|

Example: `[semver:major]`

* Squash and merge. Ensure the semver tag is preserved and entered as a part of the commit message.
* On merge, after manual approval, the orb will automatically be published to the Orb Registry.


For further questions/comments about this or other orbs, visit the Orb Category of [CircleCI Discuss](https://discuss.circleci.com/c/orbs).

