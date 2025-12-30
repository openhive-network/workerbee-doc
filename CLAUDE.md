# CLAUDE.md - WorkerBee Documentation

## Project Overview

Documentation website for **WorkerBee**, a TypeScript API library for Hive blockchain automation. WorkerBee enables developers to build bots and automation scripts using an observer pattern interface that abstracts blockchain complexity.

- **Repo**: `gitlab.syncad.com/hive/workerbee-doc`
- **Hosted**: GitLab Pages with branch preview environments
- **License**: MIT

## Tech Stack

- **Retype** (v3.11.0) - Static documentation generator
- **pnpm** (v9.1.1+) - Package manager
- **markdownlint-cli** - Markdown linting
- **Husky** - Git hooks (pre-commit linting)
- **Node.js 20** - CI runtime

## Directory Structure

```
workerbee-doc/
├── src/                        # Documentation source
│   ├── index.md                # Landing page
│   ├── closing-note.md         # Resources page
│   ├── _includes/head.html     # Custom styling (Hive theme + language persistence)
│   ├── interfaces/             # Main documentation sections
│   │   ├── getting-started.md  # Installation & quick start
│   │   ├── base-configuration.md
│   │   ├── filters.md
│   │   ├── providers.md
│   │   ├── patterns.md
│   │   ├── past-data.md
│   │   ├── core-architecture.md
│   │   ├── examples.md
│   │   └── api-reference.md
│   └── static/                 # Images & assets
│       └── snippets/           # Git submodule (workerbee-doc-snippets)
├── retype.yml                  # Site configuration
├── package.json
├── pnpm-lock.yaml
├── .markdownlint.jsonc
├── .gitlab-ci.yml
└── .husky/pre-commit           # Runs lint before commits
```

## Development Commands

```bash
pnpm install          # Install dependencies
pnpm start            # Local dev server at http://localhost:5005
pnpm build            # Build to .retype/ directory
pnpm run lint         # Lint markdown files
```

## Key Files

| File | Purpose |
|------|---------|
| `retype.yml` | Site config: branding, navigation, base URL, excluded paths |
| `src/_includes/head.html` | Custom CSS (Hive theming) + JS (language tab persistence) |
| `.markdownlint.jsonc` | Linting rules (MD041, MD013, MD045 disabled) |
| `.gitlab-ci.yml` | CI pipeline: lint → build → deploy to Pages |
| `src/static/snippets/` | Git submodule with code examples |

## Coding Conventions

### Markdown Front Matter

```yaml
---
order: -1          # Navigation order (negative = higher)
icon: home         # FontAwesome icon
label: "Optional"  # Override nav title
expanded: true     # Expand in sidebar
---
```

### Content Patterns

**Code snippets from submodule**:
```markdown
:::code source="../static/snippets/path/file.ts" language="typescript" range="17-38" title="Example"
```

**Callouts**:
```markdown
!!!warning
Important note content
!!!
```

**Line highlighting**:
````markdown
```typescript:highlight="5-7"
// code here
```
````

**Images with styling**:
```markdown
![Alt](./static/image.png){.rounded-lg width="300"}
```

**Reference links**:
```markdown
[!ref icon="repo" text="Link text"](./path/)
```

### Documentation Structure

Pages follow a learning progression:
1. Getting Started → Base Configuration → Filters (Beginner)
2. Providers → Patterns (Intermediate)
3. Past Data → Core Architecture → Examples → API Reference (Advanced)

## CI/CD Notes

**Pipeline stages**: `.pre` (lint) → `build` → `deploy`

**Deployment**:
- `main` branch → `/default/` path
- Feature branches → `/-/{branch-slug}/` (preview environments)
- Manual `cleanup_preview` job removes branch previews

**Key variables set by CI**:
- Base URL dynamically updated in `retype.yml`
- Commit SHA injected for version tracking

**Caching**: `node_modules/` and `.pnpm-store/` cached by `pnpm-lock.yaml` hash

**Git submodules**: CI uses `GIT_SUBMODULE_STRATEGY: recursive` for snippets

**Runner tags**: `public-runner-docker` (default), `data-cache-storage` (pages job)
