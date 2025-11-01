# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚨 CRITICAL PROJECT RULES (MUST FOLLOW)

### 1. Always Run Code Quality Checks Before Completion

**MANDATORY**: After ANY code changes, you MUST run these checks:

```bash
# From web/ directory
cd web && bundle exec rubocop            # Ruby style
cd web && bundle exec rspec              # Tests
cd web && bundle exec haml-lint app/views  # HAML templates

# From root directory
npm run lint:js                          # JavaScript/TypeScript
npx tsc --noEmit                        # TypeScript types
npm run build                            # Build verification
```

**Quick command** (run from web/):
```bash
make lint && bundle exec rspec && cd .. && npm run build
```

**Expected Results:**
- RuboCop: 0 offenses
- RSpec: All tests passing
- HAML-Lint: 0 lints
- ESLint: 0 errors (warnings OK)
- TypeScript: No output (success)
- Build: All assets compile successfully

### 2. Use Tailwind CSS for ALL Styling

**MANDATORY**: This project uses **Tailwind CSS exclusively**.

#### DO ✅
- Use Tailwind utility classes: `bg-blue-600`, `hover:bg-blue-700`, `focus:ring-2`
- Use responsive modifiers: `sm:`, `md:`, `lg:`, `xl:`
- Use the established color palette (see Tailwind Color System section)

#### DON'T ❌
- **DO NOT** write custom CSS classes
- **DO NOT** use inline styles (except email templates)
- **DO NOT** create new CSS files

**Color Palette** (use these consistently):
- Gray: gray-50, gray-100, gray-200, gray-300, gray-500, gray-600, gray-700, gray-900
- Blue: blue-50, blue-100, blue-500, blue-600, blue-700
- Green: green-50, green-100, green-500, green-600, green-700
- Red: red-50, red-100, red-500, red-600, red-700

### 3. Use TypeScript, NOT JavaScript

**MANDATORY**: All JavaScript files MUST be TypeScript (`.ts` or `.tsx`).

#### DO ✅
- Create `.ts` for Stimulus controllers
- Create `.tsx` for React components
- Define proper TypeScript interfaces

#### DON'T ❌
- **DO NOT** create `.js` or `.jsx` files
- **DO NOT** use `any` type

### 4. Use HAML for All View Templates

**MANDATORY**: All view templates MUST be HAML (`.html.haml`), not ERB.

#### DO ✅
- Use HAML for all new view files
- Follow 2-space indentation
- Use `=` for Ruby output, `-` for logic

#### DON'T ❌
- **DO NOT** create `.html.erb` files
- **DO NOT** use closing tags in HAML

## Project Overview

<!-- TODO: Update project description -->

**Multi-tenant SaaS application** built with Ruby on Rails 8.

**Tech Stack**:
- **Ruby**: 3.2.2
- **Rails**: 8.0 (Solid Stack: Solid Queue, Solid Cache, Solid Cable)
- **Database**: PostgreSQL
- **Frontend**: Tailwind CSS 3 + Hotwire (Turbo/Stimulus) + React 18 TypeScript
- **Templates**: HAML (100% coverage)
- **Bundling**: jsbundling-rails with esbuild (ESM format)
- **Background Jobs**: Solid Queue (database-backed, NOT Redis/Sidekiq)
- **Testing**: RSpec + FactoryBot + WebMock + Jest
- **Monorepo**: pnpm workspaces (web + mobile + shared package)

## Monorepo Structure

**Package Manager**: pnpm 9.0.0

```
project/
├── web/                      # Rails 8 backend + web frontend
│   ├── app/
│   │   ├── models/          # ActiveRecord models
│   │   ├── controllers/     # Controllers (including API v1)
│   │   ├── policies/        # Pundit policies (RBAC)
│   │   ├── services/        # Service classes
│   │   ├── jobs/           # Solid Queue jobs
│   │   ├── views/          # HAML templates
│   │   └── javascript/     # TypeScript/React components
│   ├── spec/               # RSpec tests
│   └── Makefile            # Development commands
├── mobile/                  # React Native (Expo SDK 54)
│   ├── app/                # Expo Router screens
│   └── src/
│       ├── hooks/          # React hooks (uses @uptime/shared)
│       ├── store/          # Zustand state management
│       └── components/     # React Native components
└── packages/
    └── shared/             # Shared TypeScript package
        └── src/
            ├── api/        # API clients
            ├── types/      # TypeScript interfaces
            └── validators/ # Zod schemas
```

**Working with Monorepo**:
```bash
# Install all dependencies
pnpm install

# Run commands in workspaces
pnpm --filter @uptime/shared build
pnpm --filter mobile test

# Build Rails assets (from root)
npm run build

# Run Rails tests (from web/)
cd web && bundle exec rspec
```

## Key Architecture Decisions

### 1. Multi-Tenancy: Rails 8 Native Approach

**Using Rails 8's native `Current` attributes** instead of gems.

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :organization, :organization_id, :user
end

# In controllers
Current.organization = current_user.current_organization
```

**Critical Rules**:
- All queries automatically scoped by `Current.organization_id`
- NEVER manually filter by organization_id
- Use `unscoped` only for cross-tenant queries (rare)
- Set tenant context in background jobs: `Current.organization = Organization.find(org_id)`

### 2. Authorization: Pundit with Role-Based Access Control

**4 Roles**: Owner, Admin, Member, Viewer

**Policy Pattern**:
```ruby
def create?
  user_is_member? && organization.within_quota?(:monitors)
end
```

**Always**:
- Call `authorize @resource` in controllers
- Check quotas before resource creation
- Use `policy_scope` for collection queries

### 3. Background Jobs: Solid Queue (Rails 8)

**NOT using**: Sidekiq/Redis/DelayedJob
**Using**: Solid Queue (database-backed)

**Configuration**: `config/queue.yml` + uses database instead of Redis

**Best Practices**:
- Pass IDs to jobs, not ActiveRecord objects
- Set tenant context explicitly in jobs
- Use `perform_later` (goes to Solid Queue, not Redis)

### 4. Service Layer Pattern

**Service Classes** for business logic separation.

**Pattern**:
```ruby
# In model
def perform_action
  checker = case action_type
  when 'type_a' then ServiceA.new(self)
  when 'type_b' then ServiceB.new(self)
  end

  checker.execute
end
```

### 5. Hybrid Frontend Architecture

**Strategy**: Progressive enhancement
- **Base**: HAML templates (100% HAML)
- **Interactivity**: Hotwire (Turbo Drive + Stimulus controllers)
- **Widgets**: React components (Dark mode, charts, interactive elements)

**Build Pipeline**:
1. `turbo_application.ts` → `application.js` (Hotwire + Stimulus)
2. `react_application.tsx` → `react.js` (React components)
3. `application.css` → `application.css` (Tailwind)

**React Component Mounting**:
```haml
%div{ "data-react-component": "ComponentName" }
```

React auto-mounts on `turbo:load` for SPA navigation.

### 6. API Design: Versioned REST API with JWT

**Structure**:
- `/api/v1/` - Web API (JWT authentication)
- `/api/mobile/` - Mobile-specific endpoints

**Authentication Flow**:
1. Client: POST `/api/v1/auth/login` with credentials
2. Server: Returns JWT access token + refresh token
3. Subsequent requests: `Authorization: Bearer {token}`
4. Mobile uses shared API client from `@uptime/shared`

**Rate Limiting** (Rack::Attack):
- General: 300 requests/5min per IP
- API: 1000 requests/hour per API key
- Login: 5 attempts/20sec per IP

## Development Commands

### Setup

```bash
# Initial setup (from root)
pnpm install
cd web && bin/setup

# Or manually
cd web
bundle install
bin/rails db:create db:migrate
cp .env.example .env
cd .. && pnpm install
npm run build
```

### Running the Application

```bash
# Development server (Rails + Solid Queue + Asset watching)
cd web && bin/dev

# Individual processes
cd web && bin/rails server   # Rails only
cd web && bin/jobs           # Solid Queue only

# Mobile
pnpm --filter mobile start   # Expo dev server
```

### Testing

```bash
# Rails tests
cd web && bundle exec rspec                    # All tests
cd web && bundle exec rspec spec/models/       # Model tests only
cd web && COVERAGE=true bundle exec rspec      # With coverage

# Mobile tests
pnpm --filter mobile test
pnpm --filter mobile test:coverage

# Shared package tests
pnpm --filter @uptime/shared test
```

### Code Quality

```bash
# All linters
cd web && make lint          # RuboCop + HAML-Lint
npm run lint:js              # ESLint
npx tsc --noEmit            # TypeScript

# Auto-fix
cd web && bundle exec rubocop -A
npm run lint:js:fix

# Full check before commit
cd web && make lint && bundle exec rspec && cd .. && npm run build
```

### Database

```bash
# All database commands from web/
cd web

bin/rails generate migration AddFieldToModel field:type
bin/rails db:migrate
bin/rails db:rollback
bin/rails db:reset  # CAUTION: destroys all data
```

### Solid Queue Jobs

```bash
# View jobs (from web/ console)
bin/rails console
> SolidQueue::Job.all
> SolidQueue::Job.pending.count
> SolidQueue::Job.failed.count
> SolidQueue::Job.failed.destroy_all
```

## Makefile Commands

**From web/ directory**:

```bash
make setup           # Initial project setup
make dev             # Start dev server (Rails + Solid Queue)
make console         # Rails console
make routes          # Show all routes

make db-migrate      # Run migrations
make db-rollback     # Rollback last migration
make db-reset        # Reset database (CAUTION)

make test            # Run all tests with coverage
make test-fast       # Tests without coverage
make test-file FILE=spec/models/user_spec.rb

make lint            # RuboCop + HAML-Lint
make fix             # Auto-fix RuboCop offenses

make jobs            # Start Solid Queue

make generate-controller NAME="Posts index show"
make generate-model NAME="Comment body:text"
make generate-migration NAME="AddFieldToTable"

make stats           # Project statistics
make security        # Run Brakeman security scan
```

**Full list**: Run `make help`

## I18n (Internationalization)

**Languages**: English (en), Japanese (ja)

**Translation Files**: `web/config/locales/en.yml`, `web/config/locales/ja.yml`

**Management**:
```bash
# From web/ directory
make i18n-health      # Check missing + unused translations
make i18n-missing     # Find missing keys
make i18n-unused      # Find unused keys
make i18n-normalize   # Sort and format YAML
make yaml-lint        # Validate YAML syntax
```

**Usage**:
```haml
-# In views
%h1= t('landing.hero.title')
%p= t('views.common.welcome', name: @user.name)
```

```ruby
# In controllers
flash[:notice] = t('controllers.monitors.create.notice')

# In mailers
mail(subject: t('mailers.user_mailer.welcome.subject'))
```

**Before deploying**: Always run `make i18n-health`

## React + TypeScript Integration

**Architecture**: HAML views + React widgets

**File Structure**:
```
web/app/javascript/
├── turbo_application.ts      # Turbo + Stimulus → application.js
├── react_application.tsx     # React → react.js
├── components/
│   ├── DarkModeToggle.tsx
│   ├── Button.tsx
│   └── Toast.tsx
├── hooks/
│   └── useDarkMode.ts
└── types/
    └── index.ts
```

**Embedding React in HAML**:
```haml
%div{ "data-react-component": "DarkModeToggle" }
```

**Build**:
```bash
npm run build          # All assets
npm run build:turbo    # Turbo only
npm run build:react    # React only
npm run build:css      # CSS only
```

**Linting**:
```bash
npm run lint:js        # ESLint
npm run lint:js:fix    # Auto-fix
npx tsc --noEmit      # Type checking
```

## Tailwind CSS Design System

**Core Principles**:
1. Use only Tailwind utility classes
2. No custom CSS (except CSS variables for theming)
3. Mobile-first responsive design
4. Consistent spacing and colors

**Common Patterns**:

**Page Header**:
```haml
.bg-white.border-b.border-gray-200.px-4.sm:px-6.lg:px-8.py-6
  .max-w-7xl.mx-auto.flex.items-center.justify-between
    %h1.text-3xl.font-bold.text-gray-900 Page Title
```

**Card**:
```haml
.bg-white.rounded-lg.shadow-sm.border.border-gray-200.p-6
  %h2.text-xl.font-semibold.text-gray-900.mb-4 Card Title
```

**Primary Button**:
```haml
= link_to "Action", path, class: 'inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700'
```

**Responsive Grid**:
```haml
.grid.grid-cols-1.md:grid-cols-2.lg:grid-cols-3.gap-6
```

**Exception**: Email templates use inline styles (email client compatibility)

## HAML Template Engine

**CRITICAL**: All views are HAML, NOT ERB.

**Syntax**:
```haml
# Good
.container
  %h1.title Hello World
  = link_to "Sign Up", path, class: "btn btn-primary"
  - if user.admin?
    %p.admin-notice You are an admin

# Bad - ERB-style
- if user.admin?
  %p Admin
- end  # HAML doesn't need "end"
```

**Generating Controllers**:
```bash
# From web/ directory
bin/rails generate controller Users index show --template-engine=haml

# Or use Makefile
make generate-controller NAME="Users index show"
```

**HAML is configured as default** in `web/config/application.rb`:
```ruby
config.generators do |g|
  g.template_engine :haml
end
```

## Common Gotchas

### Multi-Tenancy
- ❌ DON'T manually filter by organization_id (auto-scoped via `Current`)
- ✅ DO set tenant in controllers: `Current.organization = current_organization`
- ✅ DO set tenant in jobs: `Current.organization = Organization.find(org_id)`

### Authorization
- ❌ DON'T forget `authorize @resource` in controllers
- ✅ DO define all actions in policies
- ✅ DO use `policy_scope` for collections

### Background Jobs
- ❌ DON'T pass ActiveRecord objects (use IDs)
- ❌ DON'T assume tenant context in jobs
- ✅ DO set tenant explicitly in jobs
- ✅ DO use `perform_later` (goes to Solid Queue)

## Summary for AI Assistants

**CRITICAL REMINDERS**:

1. ✅ **ALWAYS run code quality checks** before marking tasks complete
2. ✅ **ALWAYS use Tailwind CSS** for styling (NO custom CSS)
3. ✅ **ALWAYS use TypeScript** (.ts/.tsx) for JavaScript files
4. ✅ **ALWAYS use HAML** (.html.haml) for view templates
5. ✅ **ALWAYS test changes** with `bundle exec rspec` (from web/)
6. ✅ **ALWAYS verify builds** with `npm run build` (from root)
7. ✅ **ALWAYS set tenant context** in controllers and background jobs

**Quality Standards**:
- RuboCop: 0 offenses
- RSpec: All tests passing
- HAML-Lint: 0 lints
- ESLint: 0 errors (warnings OK)
- TypeScript: 0 type errors
- Build: All assets compile successfully

**Architecture Highlights**:
- Monorepo with pnpm workspaces (web + mobile + shared)
- Rails 8 native multi-tenancy (Current attributes)
- Solid Queue for background jobs (NOT Redis/Sidekiq)
- Hybrid frontend: HAML + Hotwire + React widgets
- Service layer pattern for business logic
- 100% Tailwind CSS
