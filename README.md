# UMMS Database Migrations

Version-controlled PostgreSQL database schema migrations and integration tests for the UMMS Descriptor system.

## Project structure

```text
.
├── db/
│   ├── migrations/
│   │   ├── V001__init_tables.sql
│   │   ├── V002__constraints_and_fk.sql
│   │   └── R__seed_dictionaries.sql
│   └── tests/
│       └── integration_test_umms.sql
├── scripts/
│   ├── run_tests_ci.sh
│   └── verify_bundle.sh
├── flyway.conf
├── .gitlab-ci.yml
└── .gitignore
```

## Migration strategy

- `V001` — creates the initial database tables and primary keys.
- `V002` — adds foreign keys, unique constraints and check constraints.
- `R__seed_dictionaries.sql` — inserts or updates reference dictionary data.

Versioned migrations are applied in order. The repeatable migration maintains dictionary data.

## Requirements

- PostgreSQL 16
- Flyway 10
- Bash
- PostgreSQL client (`psql`)

## Configuration

Database credentials are supplied through environment variables. Do not commit passwords or local credential files.

The GitLab CI pipeline expects the following protected or masked CI/CD variables:

- `CI_PG_ADMIN_PASSWORD`
- `CI_PG_USER_PASSWORD`

Connection settings are configured through environment variables in the CI job.

## Validation

The project includes:

- SQL integration tests;
- a CI test runner;
- a migration bundle verification script;
- GitLab CI configuration for PostgreSQL 16 and Flyway 10.

## Verification status

Local PostgreSQL validation and Flyway-based migration execution are separate verification stages. A successful `psql` test run does not by itself establish that `flyway migrate` or the GitLab CI pipeline has passed.

## Scope

This repository contains database migrations, integration tests and automation scripts for UMMS. It does not represent the complete application source code or runtime deployment.
