# CI/CD

The project uses GitHub Actions and GitHub Container Registry (GHCR).

## Pipeline behavior

- Pull requests and pushes to non-`main` branches run CI.
- Pushes to `main` run the same CI quality gate, then publish five Docker images.
- Tags matching `v*.*.*` (for example `v1.2.0`) run CI and publish versioned images.
- Both workflows can also be started manually from the GitHub Actions page.

CI verifies:

- React frontend: `npm ci`, lint, and production build.
- Flutter app: dependency resolution, analysis, tests, and web release build.
- Four Spring Boot services: Maven `verify` on Java 21.

CD publishes these packages:

```text
ghcr.io/<owner>/<repository>-frontend
ghcr.io/<owner>/<repository>-auth-service
ghcr.io/<owner>/<repository>-product-catalog-service
ghcr.io/<owner>/<repository>-order-fulfillment-service
ghcr.io/<owner>/<repository>-support-chat-service
```

Each image receives a Git SHA tag. `main` also receives `main` and `latest`; release tags receive semantic-version tags.

## GitHub configuration

The pipeline authenticates to GHCR with the built-in `GITHUB_TOKEN`, so no registry secret is required. In **Settings > Actions > General > Workflow permissions**, allow workflows to read and write packages if organization policy has disabled it.

The frontend is compiled by Vite, so API addresses are public build-time values. Configure any applicable repository variables in **Settings > Secrets and variables > Actions > Variables**:

```text
VITE_API_URL
VITE_AUTH_API_URL
VITE_CATALOG_API_URL
VITE_ORDER_API_URL
VITE_CHAT_API_URL
VITE_CHAT_WS_URL
```

Use `VITE_API_URL` when production has one API gateway. Otherwise configure the per-service URLs. If no variables are set, the frontend keeps its current localhost fallbacks.

## Run a published image

```bash
docker pull ghcr.io/<owner>/<repository>-frontend:latest
docker run --rm -p 8080:80 ghcr.io/<owner>/<repository>-frontend:latest
```

Create a release by pushing a semantic version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflows publish deployable images; deployment to a specific server or cloud is intentionally kept separate until a target environment and its credentials are selected.
