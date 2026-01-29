# HTTPTests CircleCI Orb

CircleCI orb that does **exactly** what [httptests-action](https://github.com/serviceguards-com/httptests-action) does in GitHub Actions: automated HTTP integration testing with Docker isolation.

## Features

- Same behavior as the GitHub Action: test proxies (NGINX, Apache, Caddy) and microservices in CI/CD
- Uses the same Python scripts from the httptests-action repo (downloaded at runtime)
- Machine executor with Docker and Docker Compose
- Parameters: `httptests-directory`, `python-version`, `script-version`

## Quick Start

### 1. Add the orb to your config

In `.circleci/config.yml`:

```yaml
version: 2.1

orbs:
  httptests: your-namespace/httptests@1.0.0   # or @volatile for dev

workflows:
  test:
    jobs:
      - httptests/run:
          httptests-directory: "."
```

Replace `your-namespace/httptests` with your published orb reference (e.g. `serviceguards/httptests`).

### 2. Use a custom directory

If your `.httptests` folder is not in the repo root:

```yaml
      - httptests/run:
          httptests-directory: "./services/api-gateway"
```

### 3. Pin the script version

By default the orb fetches scripts from the `main` branch of httptests-action. To pin a version:

```yaml
      - httptests/run:
          httptests-directory: "."
          script-version: "v1.2.0"
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `httptests-directory` | string | `"."` | Path to the directory containing the `.httptests` folder |
| `python-version` | string | `"3.x"` | Python version (on machine executor, system Python 3 is used) |
| `script-version` | string | `"main"` | Branch/tag of httptests-action to fetch scripts from (e.g. `main`, `v1.2.0`) |

## Requirements

- CircleCI project with **machine** executor (Ubuntu 22.04, Docker and Docker Compose pre-installed)
- Your repo must have a `.httptests` directory (with `test.json` and optional `config.yml`) and a `Dockerfile` in the parent directory of `.httptests`

## Development (pack and validate)

From the `httptests-orb` directory:

```bash
# Pack the orb (requires CircleCI CLI)
circleci orb pack src/ > orb.yml

# Validate
circleci orb validate orb.yml
```

## License

MIT (same as httptests-action).
