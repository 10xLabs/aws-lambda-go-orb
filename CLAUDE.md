# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a CircleCI Orb project for AWS Lambda Go functions. The orb (`nexbus/aws-lambda-go`) provides commands and jobs for building, testing, linting, and deploying Go-based AWS Lambda functions.

## Key Architecture

### CircleCI Orb Structure
- **Main orb definition**: `src/@orb.yml` - Entry point for the orb
- **Commands**: `src/commands/` - Reusable command definitions
- **Jobs**: `src/jobs/` - Complete job workflows  
- **Executors**: `src/executors/` - Execution environments
- **Scripts**: `src/scripts/` - Shell scripts executed by commands
- **Examples**: `src/examples/` - Usage examples
- **Tests**: `src/tests/` - BATS tests for scripts

### Docker Image
The orb uses a custom Docker image (`nexbus/go-pulumi`) that includes Go, Pulumi, and linting tools. The image is built from the `Dockerfile` in the root directory.

## Development Commands

### Building and Publishing the Docker Image
```bash
# Build and push the Docker image
make pub

# Build for specific platform (AMD64)
docker buildx build --platform linux/amd64 . --progress=plain -t nexbus/go-pulumi:latest
```

### Working with the Orb

#### Local Development
```bash
# Validate orb YAML syntax
circleci orb validate src/@orb.yml

# Pack the orb (combine all files)
circleci orb pack src/ > orb.yml

# Run BATS tests for shell scripts
bats src/tests/

# Check shell scripts with shellcheck
shellcheck src/scripts/*.sh
```

#### Testing Changes
The orb uses a multi-stage CI/CD process:
1. **test-pack workflow**: Runs on every commit - lints, packs, and publishes dev version
2. **Integration tests**: Triggered after dev version is published
3. **Production release**: Triggered by version tags (e.g., `v1.0.0`)

### Key Orb Commands for Lambda Functions

When using this orb in a Lambda project:

```bash
# Build Lambda function (creates main executable)
# Uses: CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor
# Input: main.go → Output: main executable → Package: deploy/lambda.zip

# Run tests with coverage
# Uses gotestsum for JUnit output and go test for coverage
# Coverage threshold: 50% by default (configurable)
GOFLAGS='-mod=vendor' go test -coverprofile=cover.out -v ./...

# Lint code
golangci-lint run -v

# Run commit linting (conventional commits)
# Requires @commitlint/config-conventional configuration
```

## Release Process

The orb follows semantic versioning and uses CircleCI's orb-tools for releases:

1. **Development versions**: Automatically published as `dev:${CIRCLE_SHA1:0:7}` on every commit
2. **Production versions**: 
   - Create a git tag with version (e.g., `git tag v1.2.3`)
   - Push the tag to trigger production release
   - The orb will be published to CircleCI Orb Registry

### Pull Request Requirements
- PR titles must include semver tag: `[semver:major]`, `[semver:minor]`, `[semver:patch]`, or `[semver:skip]`
- Squash and merge, preserving the semver tag in commit message

## Important Implementation Details

- **Vendor dependencies**: The orb assumes Go projects use vendored dependencies (`-mod=vendor` flag)
- **Lambda packaging**: Builds create a zip file at `deploy/lambda.zip` containing the compiled binary
- **Test results**: JUnit XML test results are stored for CircleCI test reporting
- **Coverage artifacts**: Coverage reports are exported as HTML and stored as CircleCI artifacts
- **Pulumi support**: The orb includes Pulumi commands for infrastructure deployment