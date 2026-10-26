# CI changes to the starter's `.github/workflows/tests.yml`

The starter ships `tests.yml` with SHA-pinned actions and `composer ci:check`. Keep it, and make these changes.

## 1. pnpm

Add this step after "Setup Node":

```yaml
      - name: Setup pnpm
        run: npm install --global pnpm@<version>
```

Read the version with `pnpm -v` after you remove the `devEngines` block that `vp migrate` adds. While that block exists, `pnpm -v` prints the version it downloads, not the installed one.

## 2. Playwright (browser tests)

Add this step after "Setup Application":

```yaml
      - name: Install Playwright browsers
        run: pnpm exec playwright install --with-deps chromium
```

## 3. Database service (match `DB_CONNECTION` in `.env.example`)

- `sqlite`: no service. Tests use the phpunit.xml in-memory database.
- `pgsql`: add the service below, add `pdo_pgsql, pgsql` to the setup-php `extensions`, and add a "Create test database" step before "Setup Application".

```yaml
    services:
      postgres:
        image: postgres:17
        env:
          POSTGRES_DB: <app>
          POSTGRES_USER: postgres
          POSTGRES_HOST_AUTH_METHOD: trust
        ports:
          - 5432:5432
        options: >-
          --health-cmd="pg_isready --username=postgres"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5
```

```yaml
      - name: Create test database
        run: psql --host=127.0.0.1 --username=postgres --command='CREATE DATABASE <app>_test'
```

- `mysql`: add a `mysql:8.4` service with `MYSQL_DATABASE: <app>_test` and `MYSQL_ALLOW_EMPTY_PASSWORD: yes`, a `mysqladmin ping` health check, and `pdo_mysql` in `extensions`.

Set the matching `DB_*` values in phpunit.xml so local tests and CI use the same driver as the app.

## 4. Dependabot

Copy `templates/.github/dependabot.yml`. It updates GitHub Actions only, weekly, with a 5-day cooldown, in one grouped PR.
