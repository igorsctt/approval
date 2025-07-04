# Approval Workflow - Versão SQLite

Esta é uma versão alternativa do sistema de aprovação que usa SQLite ao invés de MongoDB, permitindo rodar sem Docker ou dependências externas.

## 🚀 Setup Rápido (SQLite)

### 1. Migrar para SQLite
```bash
./migrate_to_sqlite.sh
```

### 2. Instalar dependências
```bash
bundle install
```

### 3. Gerar migrations
```bash
rails generate migration CreateApprovals email:string description:text action_id:string callback_url:string status:string signature:string expire_at:datetime processed_at:datetime ip_address:string user_agent:string location:string
rails generate migration CreateApprovalLogs approval:references action:string ip_address:string user_agent:string location:string details:text
rails generate migration CreateUsers email:string password_digest:string name:string role:string
```

### 4. Editar migrations (opcional)
Adicione índices e validações nas migrations geradas em `db/migrate/`

### 5. Executar migrations
```bash
rails db:migrate
```

### 6. Popular banco (opcional)
```bash
rails db:seed
```

### 7. Iniciar servidor
```bash
rails server
```

## 📊 Diferenças da Versão SQLite

### Vantagens
- ✅ Sem necessidade de Docker
- ✅ Sem instalação de MongoDB
- ✅ Banco local simples
- ✅ Ideal para desenvolvimento
- ✅ Sem configurações complexas

### Desvantagens
- ❌ Menos escalável que MongoDB
- ❌ Sem queries complexas de documentos
- ❌ Estrutura mais rígida

## 🔧 Modelos SQLite

### Approval (ActiveRecord)
```ruby
class Approval < ApplicationRecord
  has_many :approval_logs, dependent: :destroy
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :action_id, presence: true
  validates :callback_url, presence: true
  validates :status, inclusion: { in: %w[created pending approved rejected expired] }
  
  enum status: { created: 0, pending: 1, approved: 2, rejected: 3, expired: 4 }
  
  scope :pending, -> { where(status: 'pending') }
  scope :expired, -> { where('expire_at < ?', Time.current) }
end
```

### ApprovalLog (ActiveRecord)
```ruby
class ApprovalLog < ApplicationRecord
  belongs_to :approval
  
  validates :action, presence: true
  validates :ip_address, presence: true
end
```

### User (ActiveRecord)
```ruby
class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
end
```

## 🗄️ Schema SQLite

```sql
-- Approvals table
CREATE TABLE approvals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  action_id VARCHAR(255) NOT NULL,
  callback_url VARCHAR(255) NOT NULL,
  status VARCHAR(50) DEFAULT 'created',
  signature VARCHAR(255),
  expire_at DATETIME,
  processed_at DATETIME,
  ip_address VARCHAR(45),
  user_agent TEXT,
  location VARCHAR(255),
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

-- Approval logs table
CREATE TABLE approval_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  approval_id INTEGER NOT NULL,
  action VARCHAR(255) NOT NULL,
  ip_address VARCHAR(45) NOT NULL,
  user_agent TEXT,
  location VARCHAR(255),
  details TEXT,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  FOREIGN KEY (approval_id) REFERENCES approvals (id)
);

-- Users table
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_digest VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

## 🧪 Testando

### Health Check
```bash
curl http://localhost:3000/health
```

### API de Aprovação
```bash
# Criar aprovação
curl -X POST http://localhost:3000/api/v1/approvals \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "description": "Teste de aprovação",
    "action_id": "test-action",
    "callback_url": "https://example.com/callback",
    "expire_at": "2024-12-31T23:59:59Z"
  }'
```

## 🔄 Voltando para MongoDB

Para voltar para a versão MongoDB:
```bash
cp Gemfile.mongoid.backup Gemfile
bundle install
git checkout config/application.rb config/mongoid.yml
```

## 📚 Comandos Úteis

```bash
# Ver tabelas
rails console
ActiveRecord::Base.connection.tables

# Reset do banco
rails db:drop db:create db:migrate db:seed

# Ver logs
tail -f log/development.log

# Console Rails
rails console

# Ver rotas
rails routes
```

## 🐛 Troubleshooting

### Erro de SQLite
```bash
sudo apt-get install sqlite3 libsqlite3-dev
```

### Erro de bundler
```bash
gem install bundler
bundle install
```

### Porta ocupada
```bash
# Matar processo na porta 3000
sudo lsof -ti:3000 | xargs kill -9
```

## 📝 Notas

- Esta versão mantém toda a funcionalidade do sistema original
- Os controllers e services permanecem os mesmos
- Apenas a camada de persistência muda (Mongoid → ActiveRecord)
- Para produção, considere usar PostgreSQL ao invés de SQLite
