#!/bin/bash
# Rails 8 Solid Starter - New Project Creator
# Usage: ./create-project.sh <project-name> [options]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where this script is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default values
PROJECT_NAME=""
TARGET_DIR="."
DATABASE="postgresql"
SKIP_BUNDLE=false
SKIP_NPM=false
SKIP_DB=false
FULL_SETUP=true

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to show usage
show_usage() {
    cat << EOF
Rails 8 Solid Starter - New Project Creator

Usage: $0 <project-name> [options]

Arguments:
  project-name              Name of the new Rails project

Options:
  -d, --dir DIR            Target directory (default: current directory)
  --skip-bundle            Skip bundle install
  --skip-npm               Skip pnpm install
  --skip-db                Skip database creation
  --minimal                Minimal setup (skip bundle, npm, db)
  -h, --help               Show this help message

Examples:
  # Basic usage
  $0 myapp

  # Specify target directory
  $0 myapp --dir ~/projects

  # Minimal setup (copy files only)
  $0 myapp --minimal

  # Skip specific steps
  $0 myapp --skip-bundle --skip-npm

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -d|--dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        --skip-bundle)
            SKIP_BUNDLE=true
            shift
            ;;
        --skip-npm)
            SKIP_NPM=true
            shift
            ;;
        --skip-db)
            SKIP_DB=true
            shift
            ;;
        --minimal)
            SKIP_BUNDLE=true
            SKIP_NPM=true
            SKIP_DB=true
            FULL_SETUP=false
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            else
                print_error "Multiple project names specified"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate project name
if [ -z "$PROJECT_NAME" ]; then
    print_error "Project name is required"
    show_usage
    exit 1
fi

# Check if project already exists
PROJECT_PATH="$TARGET_DIR/$PROJECT_NAME"
if [ -d "$PROJECT_PATH" ]; then
    print_error "Project directory already exists: $PROJECT_PATH"
    exit 1
fi

# Welcome message
print_header "Rails 8 Solid Starter - New Project Creator"
print_info "Project name: $PROJECT_NAME"
print_info "Target directory: $TARGET_DIR"
print_info "Database: $DATABASE"
echo ""

# Check prerequisites
print_header "Checking Prerequisites"

# Check Ruby
if ! command -v ruby &> /dev/null; then
    print_error "Ruby not found. Please install Ruby 3.2.2"
    exit 1
fi
RUBY_VERSION=$(ruby -v | awk '{print $2}')
print_success "Ruby $RUBY_VERSION"

# Check Rails
if ! command -v rails &> /dev/null; then
    print_error "Rails not found. Please install Rails 8.0+"
    print_info "Run: gem install rails"
    exit 1
fi
RAILS_VERSION=$(rails -v | awk '{print $2}')
print_success "Rails $RAILS_VERSION"

# Check Node.js
if ! command -v node &> /dev/null; then
    print_warning "Node.js not found. JavaScript features may not work."
else
    NODE_VERSION=$(node -v)
    print_success "Node.js $NODE_VERSION"
fi

# Check pnpm
if ! command -v pnpm &> /dev/null; then
    print_warning "pnpm not found. You may need to install it later."
    print_info "Run: npm install -g pnpm@9.0.0"
else
    PNPM_VERSION=$(pnpm -v)
    print_success "pnpm $PNPM_VERSION"
fi

# Check PostgreSQL
if ! command -v psql &> /dev/null; then
    print_warning "PostgreSQL not found. Database setup may fail."
else
    PSQL_VERSION=$(psql --version | awk '{print $3}')
    print_success "PostgreSQL $PSQL_VERSION"
fi

# Create Rails project
print_header "Creating Rails Project"
print_info "Running: rails new $PROJECT_NAME --database=$DATABASE --css=tailwind --javascript=esbuild --skip-test --skip-jbuilder"

cd "$TARGET_DIR"
rails new "$PROJECT_NAME" \
    --database="$DATABASE" \
    --css=tailwind \
    --javascript=esbuild \
    --skip-test \
    --skip-jbuilder

cd "$PROJECT_NAME"
print_success "Rails project created"

# Copy configuration files
print_header "Copying Configuration Files"

print_info "Copying linter configurations..."
cp "$SCRIPT_DIR/.rubocop.yml" .
cp "$SCRIPT_DIR/.haml-lint.yml" .
cp "$SCRIPT_DIR/eslint.config.mjs" .
cp "$SCRIPT_DIR/tsconfig.json" .
print_success "Linter configurations copied"

print_info "Copying Tailwind configuration..."
cp "$SCRIPT_DIR/tailwind.config.js" .
print_success "Tailwind configuration copied"

print_info "Copying environment and git files..."
cp "$SCRIPT_DIR/.env.example" .env
cp "$SCRIPT_DIR/.gitignore.example" .gitignore
print_success "Environment files copied"

print_info "Copying Makefile..."
cp "$SCRIPT_DIR/Makefile.example" Makefile
print_success "Makefile copied"

# Copy documentation
print_header "Copying Documentation"

print_info "Creating docs directory..."
mkdir -p docs/{features,specs,closed}
cp "$SCRIPT_DIR/CLAUDE.md" .
cp "$SCRIPT_DIR/PROJECT_TEMPLATE.md" docs/
cp "$SCRIPT_DIR/README.md" docs/STARTER_README.md
print_success "Documentation copied"

# Copy scripts
print_header "Copying Scripts and Tools"

print_info "Copying Claude Code automation scripts..."
cp -r "$SCRIPT_DIR/scripts" .
chmod +x scripts/claude-auto.sh
print_success "Scripts copied"

print_info "Copying Claude Code commands..."
cp -r "$SCRIPT_DIR/.claude" .
print_success "Claude Code commands copied"

# Copy templates
print_info "Copying code templates..."
cp -r "$SCRIPT_DIR/templates" .
print_success "Code templates copied"

# Update Gemfile
print_header "Updating Gemfile"

print_info "Adding recommended gems..."

# Add gems to Gemfile
cat >> Gemfile << 'EOF'

# ========================================
# Rails 8 Solid Starter - Additional Gems
# ========================================

# View Engine
gem 'haml-rails'

# Authentication & Authorization
gem 'devise'
gem 'devise-i18n'
gem 'pundit'

# Utilities
gem 'friendly_id'
gem 'kaminari'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
end

group :development do
  gem 'annotate'
  gem 'brakeman'
  gem 'haml_lint', require: false
  gem 'i18n-tasks'
  gem 'letter_opener'
  gem 'rubocop-rails-omakase'
  gem 'yamllint'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner-active_record'
  gem 'pundit-matchers'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

gem 'jsbundling-rails'
EOF

print_success "Gemfile updated"

# Update package.json
print_header "Updating package.json"

print_info "Adding build scripts and dependencies..."

# Create temporary package.json with updated scripts
cat > package.json.tmp << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "Rails 8 application with modern frontend stack",
  "private": true,
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "build": "npm run build:turbo && npm run build:react && npm run build:css",
    "build:turbo": "esbuild app/javascript/turbo_application.ts --bundle --sourcemap --format=esm --outfile=app/assets/builds/application.js --public-path=/assets",
    "build:react": "esbuild app/javascript/react_application.tsx --bundle --sourcemap --format=esm --outfile=app/assets/builds/react.js --public-path=/assets",
    "build:css": "tailwindcss -i ./app/assets/stylesheets/application.css -o ./app/assets/builds/application.css --minify",
    "lint": "npm run lint:js && npm run lint:css",
    "lint:js": "eslint 'app/javascript/**/*.{js,jsx,ts,tsx}'",
    "lint:css": "prettier --check 'app/assets/stylesheets/**/*.css'",
    "lint:fix": "npm run lint:js:fix && npm run lint:css:fix",
    "lint:js:fix": "eslint 'app/javascript/**/*.{js,jsx,ts,tsx}' --fix",
    "lint:css:fix": "prettier --write 'app/assets/stylesheets/**/*.css'",
    "format": "prettier --write 'app/javascript/**/*.{js,jsx,ts,tsx,json}' 'app/assets/stylesheets/**/*.css'",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "@hotwired/turbo-rails": "^8.0.4",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@tailwindcss/forms": "^0.5.7",
    "@types/react": "^18.2.45",
    "@types/react-dom": "^18.2.18",
    "@typescript-eslint/eslint-plugin": "^8.46.2",
    "@typescript-eslint/parser": "^8.46.2",
    "esbuild": "^0.25.11",
    "eslint": "^9.38.0",
    "eslint-config-prettier": "^10.1.8",
    "eslint-plugin-prettier": "^5.5.4",
    "eslint-plugin-react": "^7.37.5",
    "eslint-plugin-react-hooks": "^7.0.1",
    "prettier": "^3.6.2",
    "tailwindcss": "^3.4.0",
    "typescript": "^5.3.3"
  }
}
EOF

mv package.json.tmp package.json
print_success "package.json updated"

# Bundle install
if [ "$SKIP_BUNDLE" = false ]; then
    print_header "Installing Ruby Gems"
    print_info "Running: bundle install"
    bundle install
    print_success "Gems installed"
else
    print_warning "Skipping bundle install (use --skip-bundle flag)"
fi

# pnpm install
if [ "$SKIP_NPM" = false ]; then
    print_header "Installing npm Packages"
    if command -v pnpm &> /dev/null; then
        print_info "Running: pnpm install"
        pnpm install
        print_success "npm packages installed"
    else
        print_warning "pnpm not found. Please install manually:"
        print_info "npm install -g pnpm@9.0.0"
        print_info "pnpm install"
    fi
else
    print_warning "Skipping pnpm install (use --skip-npm flag)"
fi

# Database setup
if [ "$SKIP_DB" = false ]; then
    print_header "Setting up Database"

    print_info "Creating databases..."
    if bin/rails db:create; then
        print_success "Databases created"
    else
        print_warning "Database creation failed. You may need to start PostgreSQL."
        print_info "macOS: brew services start postgresql@16"
        print_info "Linux: sudo systemctl start postgresql"
    fi

    print_info "Installing Solid Queue..."
    bin/rails solid_queue:install
    print_success "Solid Queue installed"

    print_info "Running migrations..."
    bin/rails db:migrate
    print_success "Migrations completed"
else
    print_warning "Skipping database setup (use --skip-db flag)"
fi

# Create initial directory structure
print_header "Creating Project Structure"

print_info "Creating app directories..."
mkdir -p app/services
mkdir -p app/policies
mkdir -p app/javascript/components
mkdir -p app/javascript/hooks
mkdir -p app/javascript/types
print_success "Directories created"

# Create Current model for multi-tenancy
print_info "Creating Current model for multi-tenancy..."
cat > app/models/current.rb << 'EOF'
# frozen_string_literal: true

# Rails 8 native multi-tenancy using CurrentAttributes
# Set the current organization and user for all requests
#
# Usage in controllers:
#   Current.organization = current_user.current_organization
#   Current.user = current_user
#
# Usage in models:
#   default_scope { where(organization_id: Current.organization_id) }
class Current < ActiveSupport::CurrentAttributes
  attribute :organization, :organization_id, :user
end
EOF
print_success "Current model created"

# Create ApplicationPolicy
print_info "Creating ApplicationPolicy..."
mkdir -p app/policies
cat > app/policies/application_policy.rb << 'EOF'
# frozen_string_literal: true

# Base policy for Pundit authorization
# All other policies inherit from this class
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
EOF
print_success "ApplicationPolicy created"

# Final success message
print_header "Setup Complete!"

echo ""
print_success "Project '$PROJECT_NAME' has been created successfully!"
echo ""
print_info "Next steps:"
echo ""
echo "  1. Navigate to your project:"
echo "     ${GREEN}cd $PROJECT_NAME${NC}"
echo ""
echo "  2. Review the documentation:"
echo "     ${GREEN}cat CLAUDE.md${NC}              # Claude Code guidelines"
echo "     ${GREEN}cat docs/PROJECT_TEMPLATE.md${NC}  # Complete setup guide"
echo ""

if [ "$FULL_SETUP" = true ]; then
    echo "  3. Start the development server:"
    echo "     ${GREEN}bin/dev${NC}"
    echo ""
    echo "  4. Visit: ${BLUE}http://localhost:3000${NC}"
else
    echo "  3. Complete the setup:"
    echo "     ${GREEN}bundle install${NC}           # Install Ruby gems"
    echo "     ${GREEN}pnpm install${NC}             # Install npm packages"
    echo "     ${GREEN}bin/rails db:create${NC}      # Create databases"
    echo "     ${GREEN}bin/rails db:migrate${NC}     # Run migrations"
    echo ""
    echo "  4. Start the development server:"
    echo "     ${GREEN}bin/dev${NC}"
fi

echo ""
print_info "Available commands:"
echo "     ${GREEN}make help${NC}                # Show all Makefile commands"
echo "     ${GREEN}make lint${NC}                # Run all linters"
echo "     ${GREEN}make test${NC}                # Run all tests"
echo ""
print_info "Code templates available in: ${BLUE}templates/${NC}"
echo ""
print_success "Happy coding! 🚀"
echo ""
