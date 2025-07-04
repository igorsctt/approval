# Sistema de Aprovação KAEFER - Ruby on Rails

Um sistema moderno de gestão de aprovações desenvolvido em Ruby on Rails com autenticação por roles, interface responsiva e integração com MongoDB.

## 🚀 Características

- **Sistema de Aprovação Completo**: Criação, gestão e rastreamento de solicitações de aprovação
- **Autenticação por Roles**: Sistema de usuários com papéis admin/user
- **Interface Web Moderna**: Design responsivo com experiência mobile otimizada
- **API RESTful**: Endpoints completos para integração
- **MongoDB**: Banco de dados NoSQL com Mongoid ODM
- **Notificações por Email**: Templates HTML responsivos para emails
- **Auditoria Completa**: Log detalhado de todas as ações
- **Geolocalização**: Rastreamento por IP para logs de auditoria

## 🛠️ Stack Tecnológica

- **Backend**: Ruby 3.4.4, Rails 7.2
- **Banco de Dados**: MongoDB com Mongoid ODM
- **Autenticação**: Sistema próprio com roles (admin/user)
- **Frontend**: CSS customizado com design moderno
- **Email**: ActionMailer com templates HTML responsivos
- **Autorização**: Sistema de permissões baseado em roles

## 📱 Funcionalidades do Sistema

### Para Administradores
- ✅ Criar novas solicitações de aprovação
- ✅ Aprovar/rejeitar solicitações
- ✅ Gerenciar usuários (CRUD completo)
- ✅ Ativar/desativar usuários
- ✅ Visualizar todas as solicitações
- ✅ Acesso total ao sistema

### Para Usuários Comuns
- 👀 Visualizar solicitações (somente leitura)
- 📊 Acompanhar status das aprovações
- 🔒 Acesso restrito conforme permissões

### Interface Web
- 📱 **Totalmente Responsiva**: Mobile-first design
- 🎨 **Design Moderno**: Interface limpa e profissional
- 🔍 **Filtros Avançados**: Busca por código, status, data e título
- 📋 **Cards Informativos**: Layout em cards para melhor visualização
- 🎯 **Navegação Intuitiva**: UX otimizada para todos os dispositivos

## 🏗️ Arquitetura do Sistema

### Controllers
```
app/controllers/
├── application_controller.rb         # Controller base com autenticação
├── auth_controller.rb               # Autenticação de usuários
├── approvals_controller.rb          # Gestão de aprovações
├── users_controller.rb              # Gestão de usuários (admin)
├── health_controller.rb             # Health check
├── concerns/
│   └── authorization.rb             # Concern de autorização
└── api/v1/                         # API endpoints
    ├── auth_controller.rb
    └── approvals_controller.rb
```

### Models
```
app/models/
├── user.rb                         # Modelo de usuários com roles
├── approval.rb                     # Modelo de aprovações
└── approval_log.rb                 # Logs de auditoria
```

### Views Responsivas
```
app/views/
├── layouts/
│   └── application.html.erb        # Layout principal com header KAEFER
├── auth/
│   └── login.html.erb              # Página de login
├── approvals/
│   ├── index.html.erb              # Lista de aprovações
│   ├── new.html.erb                # Nova solicitação
│   └── show.html.erb               # Detalhes da aprovação
├── users/                          # Gestão de usuários
│   ├── index.html.erb              # Lista responsiva
│   ├── new.html.erb                # Criar usuário
│   ├── edit.html.erb               # Editar usuário
│   └── show.html.erb               # Detalhes do usuário
└── approval_mailer/                # Templates de email
    ├── approval_request.html.erb
    ├── approval_approved.html.erb
    ├── approval_rejected.html.erb
    └── approval_expired.html.erb
```

### Services
```
app/services/
├── approval_service.rb             # Lógica de aprovações
├── email_service.rb                # Serviço de emails
├── jwt_service.rb                  # Gestão de JWT tokens
└── geolocation_service.rb          # Geolocalização por IP
```

## 🚀 Instalação

### 1. Pré-requisitos
```bash
# Ruby 3.4.4
# MongoDB
# Node.js (para assets)
```

### 2. Clone e Setup
```bash
git clone <repository-url>
cd approval-rb

# Instalar dependências
bundle install

# Configurar variáveis de ambiente
cp .env.example .env
# Edite o .env com suas configurações
```

### 3. Configuração do MongoDB
```bash
# Iniciar MongoDB
mongod

# O banco será criado automaticamente
```

### 4. Setup Inicial
```bash
# Criar usuários iniciais
ruby create_users.rb

# Iniciar servidor
rails server
```

### 5. Credenciais Padrão
```
ADMINISTRADOR:
  Email: admin@kaefer.com
  Senha: admin123
  Permissões: Acesso total

USUÁRIO COMUM:
  Email: usuario@kaefer.com
  Senha: user123
  Permissões: Somente visualização
```

## 🔗 Rotas do Sistema

### Web Interface
```ruby
# Autenticação
GET  /login                    # Página de login
POST /authenticate             # Processar login
DELETE /logout                 # Logout

# Aprovações
GET  /approvals               # Lista de aprovações
GET  /approvals/new           # Nova solicitação
POST /approvals               # Criar solicitação
GET  /approvals/:id           # Detalhes
PATCH /approvals/:id/approve  # Aprovar
PATCH /approvals/:id/reject   # Rejeitar

# Usuários (Admin)
GET  /users                   # Lista de usuários
GET  /users/new               # Novo usuário
POST /users                   # Criar usuário
GET  /users/:id/edit          # Editar usuário
PATCH /users/:id              # Atualizar usuário
DELETE /users/:id             # Excluir usuário
PATCH /users/:id/toggle_status # Ativar/Desativar

# Raiz
GET  /                        # Redireciona para login
```

### API Endpoints
```ruby
# Autenticação API
POST /api/v1/auth/login       # Login via API
POST /api/v1/auth/validate    # Validar token

# Aprovações API
GET  /api/v1/approvals        # Listar aprovações
POST /api/v1/approvals        # Criar aprovação
GET  /api/v1/approvals/:id    # Detalhes
PUT  /api/v1/approvals/approve # Aprovar
PUT  /api/v1/approvals/reject  # Rejeitar

# Health Check
GET  /health                  # Status da aplicação
```

## 🔐 Sistema de Autenticação

### Roles e Permissões
```ruby
# Admin
- Criar solicitações de aprovação
- Aprovar/rejeitar solicitações
- Gerenciar usuários (CRUD)
- Ativar/desativar usuários
- Acesso total ao sistema

# User
- Visualizar solicitações (read-only)
- Acompanhar status das aprovações
- Sem permissões de modificação
```

### Middleware de Autorização
```ruby
# app/controllers/concerns/authorization.rb
# Controla acesso baseado em roles
# Redireciona usuários não autorizados
# Protege rotas administrativas
```

## 📧 Sistema de Email

### Templates Responsivos
- **approval_request.html.erb**: Notificação de nova solicitação
- **approval_approved.html.erb**: Confirmação de aprovação
- **approval_rejected.html.erb**: Notificação de rejeição
- **approval_expired.html.erb**: Alerta de expiração

### Configuração SMTP
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
SMTP_DOMAIN=gmail.com
```

## 🎨 Design e Responsividade

### Características do Design
- **Mobile-First**: Otimizado para dispositivos móveis
- **Cards Layout**: Interface em cards para melhor organização
- **Filtros Inteligentes**: Busca avançada com múltiplos critérios
- **Botões Adaptativos**: Tamanhos e posições otimizadas para mobile
- **Header Fixo**: Logo KAEFER e navegação sempre visíveis
- **Feedback Visual**: Estados hover, focus e transições suaves

### Breakpoints
```css
/* Mobile: < 768px */
/* Tablet: 768px - 1024px */
/* Desktop: > 1024px */
```

## 🧪 Exemplo de Uso da API

### Criar Solicitação
```bash
curl -X POST http://localhost:3000/api/v1/approvals \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "requester_email": "solicitante@kaefer.com",
    "approver_email": "aprovador@kaefer.com",
    "description": "Aprovação de orçamento Q1 2025",
    "action_id": "BUDGET-2025-Q1",
    "callback_url": "https://sistema.kaefer.com/callback",
    "details": {
      "valor": 50000,
      "departamento": "Marketing",
      "categoria": "Orçamento"
    }
  }'
```

### Validar Token
```bash
curl -X GET "http://localhost:3000/api/v1/approvals/validate?token=JWT_TOKEN"
```

### Aprovar Solicitação
```bash
curl -X PUT http://localhost:3000/api/v1/approvals/approve \
  -H "Content-Type: application/json" \
  -d '{
    "token": "APPROVAL_JWT_TOKEN",
    "signature": "João Silva - Gerente"
  }'
```

## 🗄️ Estrutura do Banco de Dados

### Collections MongoDB

#### Users
```javascript
{
  _id: ObjectId,
  email: String,           // Único
  name: String,
  password_digest: String, // BCrypt hash
  role: String,           // "admin" | "user"
  active: Boolean,        // Status do usuário
  last_login_at: Date,
  login_count: Number,
  created_at: Date,
  updated_at: Date
}
```

#### Approvals
```javascript
{
  _id: ObjectId,
  action_id: String,       // Código da solicitação
  description: String,     // Descrição detalhada
  requester_email: String, // Email do solicitante
  approver_email: String,  // Email do aprovador
  status: String,         // "pending" | "approved" | "rejected"
  callback_url: String,   // URL para notificação
  details: Object,        // Dados adicionais
  expire_at: Date,        // Data de expiração
  processed_at: Date,     // Data de processamento
  signature: String,      // Assinatura do aprovador
  ip_address: String,     // IP do aprovador
  user_agent: String,     // User Agent
  location: Object,       // Dados de geolocalização
  created_at: Date,
  updated_at: Date
}
```

#### ApprovalLogs
```javascript
{
  _id: ObjectId,
  approval_id: ObjectId,   // Referência à aprovação
  action: String,         // "created" | "approved" | "rejected"
  ip_address: String,
  user_agent: String,
  location: Object,
  details: Object,        // Dados adicionais da ação
  created_at: Date,
  updated_at: Date
}
```

## 🔧 Configuração de Ambiente

### Variáveis Obrigatórias (.env)
```env
# Banco de Dados
MONGODB_URI=mongodb://localhost:27017/approval_workflow_development

# JWT
JWT_SECRET=sua-chave-secreta-super-segura
JWT_EXPIRATION=24h

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@kaefer.com
SMTP_PASSWORD=sua-senha-app
SMTP_DOMAIN=kaefer.com

# Aplicação
APPROVAL_URL=http://localhost:3000
RAILS_ENV=development
RAILS_MASTER_KEY=sua-master-key
```

## 🛡️ Segurança

### Medidas Implementadas
- **Autenticação Obrigatória**: Todas as rotas protegidas
- **Autorização por Roles**: Controle granular de permissões
- **BCrypt**: Hash seguro de senhas
- **JWT Tokens**: Autenticação stateless para API
- **CSRF Protection**: Proteção contra ataques CSRF
- **Validação de Dados**: Sanitização de inputs
- **Auditoria Completa**: Log de todas as ações

## 🚀 Deploy

### Preparação para Produção
```bash
# Compilar assets
rails assets:precompile

# Variáveis de produção
RAILS_ENV=production
MONGODB_URI=mongodb://seu-servidor-mongo/approval_workflow_production

# SSL/HTTPS obrigatório em produção
FORCE_SSL=true
```

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Faça suas alterações
4. Teste: `rails test` (quando implementado)
5. Commit: `git commit -am 'Adiciona nova funcionalidade'`
6. Push: `git push origin feature/nova-funcionalidade`
7. Crie um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT.

---

**Sistema de Aprovação KAEFER** - Desenvolvido com ❤️ para otimizar processos de aprovação empresarial.
