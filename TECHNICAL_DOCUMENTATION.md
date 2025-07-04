# Documentação Técnica - Sistema de Aprovação KAEFER

## 🏗️ Arquitetura do Sistema

### Padrão MVC + Services
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Controllers   │───▶│    Services     │───▶│     Models      │
│                 │    │                 │    │                 │
│ • Auth          │    │ • Approval      │    │ • User          │
│ • Approvals     │    │ • Email         │    │ • Approval      │
│ • Users         │    │ • JWT           │    │ • ApprovalLog   │
│ • Health        │    │ • Geolocation   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Fluxo de Autenticação
```
1. Login (auth#authenticate)
   ↓
2. Verificação BCrypt
   ↓
3. Criação de Sessão
   ↓
4. Redirect baseado em Role
   ↓
5. Authorization Middleware (API)
```

### Fluxo de Aprovação
```
1. Criar Solicitação
   ↓
2. Envio de Email
   ↓
3. Link com JWT Token
   ↓
4. Validação do Token
   ↓
5. Ação (Aprovar/Rejeitar)
   ↓
6. Notificação por Email
   ↓
7. Log de Auditoria
```

## 🔐 Sistema de Segurança

### Autenticação Web
```ruby
# app/controllers/concerns/authorization.rb
module Authorization
  def authenticate_user!
    redirect_to login_path unless current_user
  end
  
  def require_admin!
    redirect_to root_path unless current_user&.admin?
  end
end
```

### Autenticação API
```ruby
# app/middlewares/authorization_middleware.rb
class AuthorizationMiddleware
  def call(env)
    token = extract_token(request)
    user = User.find_by_token(token)
    return unauthorized_response unless user
    
    env['current_user'] = user
    @app.call(env)
  end
end
```

### Proteção de Rotas
```ruby
# Rotas Web
before_action :authenticate_user!
before_action :require_admin!, only: [:create, :update, :destroy]

# Rotas API
config.middleware.use AuthorizationMiddleware
```

## 📊 Modelos de Dados

### User Model
```ruby
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Campos
  field :email, type: String
  field :name, type: String
  field :password_digest, type: String
  field :role, type: String, default: 'user'
  field :active, type: Boolean, default: true
  field :last_login_at, type: Time
  field :login_count, type: Integer, default: 0
  
  # Validações
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[user admin] }
  
  # Métodos
  def admin?; role == 'admin'; end
  def authenticate_password(password)
    BCrypt::Password.new(password_digest) == password
  end
end
```

### Approval Model
```ruby
class Approval
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Relacionamentos
  has_many :approval_logs, dependent: :destroy
  
  # Campos principais
  field :action_id, type: String
  field :description, type: String
  field :requester_email, type: String
  field :approver_email, type: String
  field :status, type: String, default: 'pending'
  field :details, type: Hash, default: {}
  
  # Campos de controle
  field :expire_at, type: Time
  field :processed_at, type: Time
  field :signature, type: String
  
  # Auditoria
  field :ip_address, type: String
  field :user_agent, type: String
  field :location, type: Hash
  
  # Validações
  validates :action_id, presence: true, uniqueness: true
  validates :description, presence: true, length: { minimum: 10 }
  validates :status, inclusion: { in: %w[pending approved rejected expired] }
end
```

## 🎯 Services

### ApprovalService
```ruby
class ApprovalService
  def self.create_approval(params)
    approval = Approval.new(params)
    
    if approval.save
      # Enviar email
      EmailService.send_approval_request(approval)
      
      # Log de criação
      create_log(approval, 'created')
      
      { success: true, data: approval }
    else
      { success: false, errors: approval.errors }
    end
  end
  
  def self.process_approval(token, action, signature)
    approval = validate_token(token)
    return { success: false, error: 'Invalid token' } unless approval
    
    approval.update!(
      status: action,
      signature: signature,
      processed_at: Time.current
    )
    
    # Enviar email de confirmação
    EmailService.send_approval_result(approval)
    
    # Log da ação
    create_log(approval, action)
    
    { success: true, data: approval }
  end
end
```

### EmailService
```ruby
class EmailService
  def self.send_approval_request(approval)
    ApprovalMailer.approval_request(approval).deliver_now
  end
  
  def self.send_approval_result(approval)
    case approval.status
    when 'approved'
      ApprovalMailer.approval_approved(approval).deliver_now
    when 'rejected'
      ApprovalMailer.approval_rejected(approval).deliver_now
    end
  end
end
```

### JwtService
```ruby
class JwtService
  SECRET = Rails.application.credentials.jwt_secret
  
  def self.encode(payload)
    JWT.encode(payload, SECRET, 'HS256')
  end
  
  def self.decode(token)
    JWT.decode(token, SECRET, true, { algorithm: 'HS256' })[0]
  rescue JWT::DecodeError
    nil
  end
end
```

## 📧 Sistema de Email

### Templates Responsivos
```html
<!-- app/views/approval_mailer/approval_request.html.erb -->
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    /* CSS responsivo inline */
    @media only screen and (max-width: 600px) {
      .container { width: 100% !important; }
      .content { padding: 20px !important; }
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Nova Solicitação de Aprovação</h1>
    <p>Você recebeu uma nova solicitação para aprovação:</p>
    
    <div class="approval-details">
      <h3><%= @approval.action_id %></h3>
      <p><%= @approval.description %></p>
    </div>
    
    <div class="actions">
      <a href="<%= approve_url %>" class="btn btn-approve">
        ✅ Aprovar
      </a>
      <a href="<%= reject_url %>" class="btn btn-reject">
        ❌ Rejeitar
      </a>
    </div>
  </div>
</body>
</html>
```

### Configuração SMTP
```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_HOST'],
  port: ENV['SMTP_PORT'],
  domain: ENV['SMTP_DOMAIN'],
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

## 🎨 Frontend Responsivo

### CSS Grid Layout
```css
/* app/views/approvals/new.html.erb */
.content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
}

@media (min-width: 1024px) {
  .content-wrapper {
    grid-template-columns: 2fr 1fr;
  }
}
```

### Cards Responsivos
```css
.approval-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.2s;
}

.approval-card:hover {
  transform: translateY(-2px);
}

@media (max-width: 768px) {
  .approval-actions {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
  }
}
```

### JavaScript para Navegação
```javascript
// Layout application.html.erb
document.addEventListener('click', function(e) {
  const link = e.target.closest('a[data-method]');
  if (!link) return;
  
  const method = link.getAttribute('data-method');
  if (method && method.toLowerCase() !== 'get') {
    e.preventDefault();
    
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = link.href;
    
    // Adicionar CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]');
    if (csrfToken) {
      const csrfInput = document.createElement('input');
      csrfInput.type = 'hidden';
      csrfInput.name = 'authenticity_token';
      csrfInput.value = csrfToken.content;
      form.appendChild(csrfInput);
    }
    
    document.body.appendChild(form);
    form.submit();
  }
});
```

## 📱 Responsividade

### Breakpoints
```scss
// Mobile First Approach
$mobile: 320px;
$tablet: 768px;
$desktop: 1024px;
$wide: 1440px;

@mixin mobile {
  @media (max-width: #{$tablet - 1px}) { @content; }
}

@mixin tablet {
  @media (min-width: #{$tablet}) and (max-width: #{$desktop - 1px}) { @content; }
}

@mixin desktop {
  @media (min-width: #{$desktop}) { @content; }
}
```

### Design System
```css
/* Cores */
:root {
  --primary: #3b82f6;
  --secondary: #6b7280;
  --success: #16a34a;
  --danger: #dc2626;
  --warning: #d97706;
  
  --bg-primary: #ffffff;
  --bg-secondary: #f8fafc;
  --text-primary: #1f2937;
  --text-secondary: #6b7280;
  
  --border-radius: 8px;
  --shadow: 0 2px 8px rgba(0,0,0,0.1);
}

/* Componentes */
.btn {
  padding: 0.75rem 1.5rem;
  border-radius: var(--border-radius);
  font-weight: 600;
  transition: all 0.2s;
  cursor: pointer;
  border: none;
}

.card {
  background: var(--bg-primary);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow);
  padding: 1.5rem;
}
```

## 🔍 Debugging e Logs

### Logs Estruturados
```ruby
# config/application.rb
config.log_level = :info
config.log_formatter = ::Logger::Formatter.new

# Para produção
if Rails.env.production?
  config.logger = ActiveSupport::Logger.new(STDOUT)
  config.log_level = :info
end
```

### Health Check
```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def show
    health_status = {
      status: 'healthy',
      timestamp: Time.current,
      database: check_database,
      version: Rails.application.config.version
    }
    
    render json: health_status
  end
  
  private
  
  def check_database
    User.count
    'connected'
  rescue StandardError
    'disconnected'
  end
end
```

## 🚀 Performance

### Otimizações Implementadas
- **Indexação MongoDB**: Campos principais indexados
- **Lazy Loading**: Carregamento sob demanda
- **Caching**: Cache de queries frequentes
- **Minificação**: Assets otimizados para produção

### Métricas
```ruby
# Gemfile (para monitoramento)
gem 'rack-mini-profiler'
gem 'memory_profiler'
gem 'stackprof'
```

## 🛠️ Manutenção

### Backup MongoDB
```bash
# Backup
mongodump --db approval_workflow_production --out /backup/

# Restore
mongorestore --db approval_workflow_production /backup/approval_workflow_production/
```

### Logs de Auditoria
```ruby
# Verificar logs de aprovação
ApprovalLog.where(action: 'approved').desc(:created_at).limit(100)

# Estatísticas de uso
User.active.where(:last_login_at.gte => 30.days.ago).count
Approval.where(:created_at.gte => 1.month.ago).group_by(&:status)
```

---

Esta documentação técnica complementa o README principal e fornece detalhes de implementação para desenvolvedores e administradores do sistema.
