# Executors

Easily author and add [Parameterized Executors](https://circleci.com/docs/2.0/reusing-config/#executors) to the `src/executors` directory.

Each _YAML_ file within this directory will be treated as an orb executor, with a name which matches its filename.

Executors can be used to parameterize the same environment across many jobs. Orbs nor jobs _require_ executors, but may be helpful in some cases, such as: [parameterizing the Go version for a testing job so that matrix testing may be used](https://circleci.com/orbs/registry/orb/circleci/go#usage-run_matrix_testing).

View the included _[hello.yml](./hello.yml)_ example.


```yaml
description: >
  This is a sample executor using Docker and Go.
docker:
  - image: 'cimg/go:<< parameters.tag >>'
parameters:
  tag:
    default: lts
    description: >
      Pick a specific circleci/go image variant:
      https://hub.docker.com/r/cimg/go/tags
    type: string
```

## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How To Author Executors](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-executors)
 - [Go Orb Executor](https://github.com/CircleCI-Public/go-orb/blob/master/src/executors/default.yml)