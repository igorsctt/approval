#!/bin/bash

echo "🔄 Migração Completa para SQLite..."
echo "=================================="

# Verificar se estamos no diretório correto
if [ ! -f "Gemfile" ]; then
    echo "❌ Erro: Execute este script no diretório raiz do projeto Rails"
    exit 1
fi

# Backup dos arquivos originais
echo "📦 Fazendo backup dos arquivos originais..."
mkdir -p backup
cp Gemfile backup/Gemfile.mongoid
cp -r app/models backup/models_mongoid
cp -r config backup/config_mongoid

# Atualizar Gemfile
echo "📝 Atualizando Gemfile para SQLite..."
cat > Gemfile << 'EOF'
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

gem 'rails', '~> 7.2.0'
gem 'sqlite3', '~> 1.4'
gem 'puma', '~> 6.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder', '~> 2.7'
gem 'bcrypt', '~> 3.1.7'
gem 'jwt'
gem 'rack-cors'
gem 'mail'
gem 'httparty'
gem 'geoip'
gem 'tailwindcss-rails'

group :development, :test do
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'letter_opener'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
EOF

# Criar database.yml
echo "🗄️ Configurando database.yml..."
cat > config/database.yml << 'EOF'
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  database: db/production.sqlite3
EOF

# Atualizar application.rb
echo "⚙️ Atualizando application.rb..."
cat > config/application.rb << 'EOF'
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module ApprovalWorkflow
  class Application < Rails::Application
    config.load_defaults 7.2
    config.generators.system_tests = nil

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options, :head]
      end
    end

    config.time_zone = 'UTC'
    config.active_job.queue_adapter = :async
    config.log_level = :info
    config.logger = Logger.new(STDOUT)
    config.logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
    end
  end
end
EOF

# Remover arquivos do Mongoid
echo "🗑️ Removendo configurações do Mongoid..."
rm -f config/mongoid.yml
rm -f config/initializers/mongoid.rb

# Atualizar models para ActiveRecord
echo "🔧 Atualizando models para ActiveRecord..."

# Approval model
cat > app/models/approval.rb << 'EOF'
class Approval < ApplicationRecord
  has_many :approval_logs, dependent: :destroy
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :action_id, presence: true
  validates :callback_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :status, inclusion: { in: %w[created pending approved rejected expired] }
  
  enum status: { created: 0, pending: 1, approved: 2, rejected: 3, expired: 4 }
  
  scope :pending, -> { where(status: 'pending') }
  scope :expired, -> { where('expire_at < ?', Time.current) }
  scope :by_email, ->(email) { where(email: email) }
  
  before_create :set_default_status
  before_save :set_processed_at
  
  def expired?
    expire_at.present? && expire_at < Time.current
  end
  
  def pending?
    status == 'pending'
  end
  
  def completed?
    %w[approved rejected].include?(status)
  end
  
  def approve!(ip_address: nil, user_agent: nil, location: nil)
    transaction do
      update!(status: 'approved', processed_at: Time.current)
      approval_logs.create!(
        action: 'approved',
        ip_address: ip_address,
        user_agent: user_agent,
        location: location
      )
    end
  end
  
  def reject!(ip_address: nil, user_agent: nil, location: nil, reason: nil)
    transaction do
      update!(status: 'rejected', processed_at: Time.current)
      approval_logs.create!(
        action: 'rejected',
        ip_address: ip_address,
        user_agent: user_agent,
        location: location,
        details: reason
      )
    end
  end
  
  def expire!
    transaction do
      update!(status: 'expired', processed_at: Time.current)
      approval_logs.create!(
        action: 'expired',
        ip_address: 'system',
        user_agent: 'system',
        location: 'system'
      )
    end
  end
  
  def log_view(ip_address: nil, user_agent: nil, location: nil)
    approval_logs.create!(
      action: 'viewed',
      ip_address: ip_address,
      user_agent: user_agent,
      location: location
    )
  end
  
  def log_action(action, ip_address: nil, user_agent: nil, location: nil, details: nil)
    approval_logs.create!(
      action: action,
      ip_address: ip_address,
      user_agent: user_agent,
      location: location,
      details: details
    )
  end
  
  def self.cleanup_expired
    expired.find_each do |approval|
      approval.expire!
    end
  end
  
  private
  
  def set_default_status
    self.status ||= 'created'
  end
  
  def set_processed_at
    if status_changed? && completed?
      self.processed_at = Time.current
    end
  end
end
EOF

# ApprovalLog model
cat > app/models/approval_log.rb << 'EOF'
class ApprovalLog < ApplicationRecord
  belongs_to :approval
  
  validates :action, presence: true
  validates :ip_address, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  
  def self.actions
    %w[created viewed approved rejected expired reminded]
  end
end
EOF

# User model
cat > app/models/user.rb << 'EOF'
class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, inclusion: { in: %w[admin user] }
  
  enum role: { user: 0, admin: 1 }
  
  scope :admins, -> { where(role: 'admin') }
  scope :users, -> { where(role: 'user') }
  
  def admin?
    role == 'admin'
  end
  
  def can_approve?
    admin?
  end
end
EOF

# Criar ApplicationRecord se não existir
if [ ! -f "app/models/application_record.rb" ]; then
    cat > app/models/application_record.rb << 'EOF'
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
EOF
fi

echo "✅ Migração concluída!"
echo ""
echo "📋 Próximos passos:"
echo "1. bundle install"
echo "2. rails generate migration CreateApprovals"
echo "3. rails generate migration CreateApprovalLogs"
echo "4. rails generate migration CreateUsers"
echo "5. Edite as migrations geradas"
echo "6. rails db:migrate"
echo "7. rails db:seed"
echo "8. rails server"
echo ""
echo "📖 Consulte README_SQLITE.md para mais detalhes"
