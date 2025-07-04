# 🌐 Deploy Gratuito - Sistema de Aprovação KAEFER

Guia completo para colocar o sistema online **gratuitamente** usando plataformas cloud.

## 🏆 Melhores Opções Gratuitas

### 1. **Railway** (Recomendado) 🚂
- ✅ **MongoDB Atlas gratuito** incluído
- ✅ **SSL automático**
- ✅ **Deploy automático** via Git
- ✅ **500h/mês grátis** (suficiente para uso contínuo)
- ✅ **Domínio personalizado** gratuito

### 2. **Heroku** (Alternativa)
- ✅ **550h/mês grátis**
- ✅ **Add-ons gratuitos**
- ✅ **Git deploy**
- ⚠️ **Dorme após 30min** sem uso

### 3. **Render** (Opção moderna)
- ✅ **750h/mês grátis**
- ✅ **SSL gratuito**
- ✅ **PostgreSQL gratuito**
- ⚠️ **Limitações de memória**

---

## 🚂 Deploy no Railway (Recomendado)

### Passo 1: Preparar o Projeto

Primeiro, vamos criar os arquivos necessários para o deploy:

#### 1.1 Criar Procfile
```bash
# Procfile (na raiz do projeto)
web: bundle exec puma -C config/puma.rb
```

#### 1.2 Configurar Puma para Railway
```ruby
# config/puma.rb
workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000
environment ENV['RAILS_ENV'] || 'development'

on_worker_boot do
  # Configuração específica para Mongoid
  if defined?(Mongoid)
    Mongoid.load!(Rails.root.join('config', 'mongoid.yml'), Rails.env)
  end
end

# Permite reinicialização
plugin :tmp_restart
```

#### 1.3 Configurar Produção Rails
```ruby
# config/environments/production.rb
Rails.application.configure do
  # ...existing code...
  
  # Adicionar estas linhas para Railway:
  config.serve_static_assets = true
  config.assets.compile = true
  config.force_ssl = false  # Railway cuida do SSL
  config.log_level = :info
  config.logger = Logger.new(STDOUT)
  
  # Permitir hosts do Railway
  config.hosts << /.*\.railway\.app/
  config.hosts << /.*\.up\.railway\.app/
end
```

### Passo 2: MongoDB Atlas Gratuito

#### 2.1 Criar Conta MongoDB Atlas
1. Acesse: https://www.mongodb.com/cloud/atlas
2. Crie conta gratuita
3. Crie cluster gratuito (M0 Sandbox)
4. Configure usuário do banco
5. Adicione IP `0.0.0.0/0` (permitir de qualquer lugar)
6. Copie a string de conexão

#### 2.2 String de Conexão
```
mongodb+srv://usuario:senha@cluster0.xxxxx.mongodb.net/approval_production?retryWrites=true&w=majority
```

### Passo 3: Deploy no Railway

#### 3.1 Preparar Repositório
```bash
# Adicionar arquivos ao Git
git add .
git commit -m "Preparar para deploy Railway"
git push origin main
```

#### 3.2 Fazer Deploy
1. Acesse: https://railway.app
2. **Login com GitHub**
3. **"New Project" → "Deploy from GitHub repo"**
4. Selecione seu repositório
5. Railway detectará automaticamente que é Rails

#### 3.3 Configurar Variáveis de Ambiente
No painel do Railway, vá em **Variables** e adicione:

```env
# Produção
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# MongoDB Atlas
MONGODB_URI=mongodb+srv://usuario:senha@cluster0.xxxxx.mongodb.net/approval_production

# JWT (gere uma chave aleatória)
JWT_SECRET=sua-chave-super-secreta-de-32-caracteres-minimo

# Rails Master Key (do arquivo config/master.key)
RAILS_MASTER_KEY=sua-master-key-aqui

# Email (configurar depois)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
SMTP_DOMAIN=gmail.com
```

#### 3.4 Gerar Master Key
```bash
# Se não tiver master.key, gere uma nova:
rails credentials:edit
# Ou use uma chave aleatória:
openssl rand -hex 32
```

### Passo 4: Configuração Final

#### 4.1 Adicionar Seeds para Produção
```ruby
# db/seeds.rb ou executar via Railway console
User.create!(
  name: 'Administrador KAEFER',
  email: 'admin@kaefer.com',
  password: 'admin123',
  role: 'admin',
  active: true
) unless User.find_by(email: 'admin@kaefer.com')

puts "✅ Usuário admin criado: admin@kaefer.com / admin123"
```

#### 4.2 Executar Seeds
No Railway console ou após deploy:
```bash
rails db:seed
```

---

## 🌊 Deploy Alternativo - Heroku

### Passo 1: Preparar para Heroku

#### 1.1 Instalar Heroku CLI
```bash
# Ubuntu/WSL
curl https://cli-assets.heroku.com/install.sh | sh

# macOS
brew tap heroku/brew && brew install heroku
```

#### 1.2 Login e Criar App
```bash
heroku login
heroku create kaefer-approval-system
```

#### 1.3 Adicionar MongoDB
```bash
# Adicionar MongoDB Atlas ou mLab
heroku addons:create mongolab:sandbox
# Ou configurar manualmente com MongoDB Atlas
```

### Passo 2: Configurar Variáveis Heroku
```bash
heroku config:set RAILS_ENV=production
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set RAILS_LOG_TO_STDOUT=true
heroku config:set JWT_SECRET="sua-chave-secreta"
heroku config:set RAILS_MASTER_KEY="sua-master-key"
heroku config:set MONGODB_URI="sua-string-mongodb"
```

### Passo 3: Deploy
```bash
git push heroku main
heroku run rails db:seed
heroku open
```

---

## 🎯 Render (Opção 3)

### Deploy no Render
1. Acesse: https://render.com
2. Conecte GitHub
3. Crie "Web Service"
4. Configure:
   - **Build Command**: `bundle install && rails assets:precompile`
   - **Start Command**: `bundle exec puma -C config/puma.rb`

---

## 📧 Configuração de Email Gratuito

### Gmail SMTP (Recomendado)
1. **Ativar autenticação 2 fatores** na conta Gmail
2. **Gerar senha de app**:
   - Google Account → Security → 2-Step Verification → App passwords
   - Selecionar "Mail" e dispositivo
   - Copiar senha gerada

### Variáveis de Email
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=senha-app-gerada-pelo-google
SMTP_DOMAIN=gmail.com
```

---

## 🔗 Domínio Personalizado Gratuito

### Railway
- **Domínio gratuito**: `seu-app.railway.app`
- **Domínio personalizado**: Adicionar no painel (gratuito)

### Freenom (Domínio .tk, .ml, .ga grátis)
1. Acesse: https://freenom.com
2. Registre domínio gratuito
3. Configure DNS para apontar para Railway/Heroku

### Cloudflare (SSL + CDN gratuito)
1. Adicione site no Cloudflare
2. Configure nameservers
3. SSL automático e CDN

---

## 🚀 Checklist de Deploy

### ✅ Antes do Deploy
- [ ] Procfile criado
- [ ] config/puma.rb configurado para produção
- [ ] config/environments/production.rb ajustado
- [ ] MongoDB Atlas configurado
- [ ] Variáveis de ambiente definidas
- [ ] Master key gerada
- [ ] Código commitado no Git

### ✅ Após Deploy
- [ ] Aplicação acessível via URL
- [ ] Banco conectado (verificar logs)
- [ ] Seeds executados (usuário admin criado)
- [ ] Login funcionando
- [ ] Email configurado (opcional inicialmente)
- [ ] SSL ativo

### ✅ Testes de Funcionamento
- [ ] Login com admin@kaefer.com / admin123
- [ ] Criar nova aprovação
- [ ] Gerenciar usuários
- [ ] Interface responsiva no mobile
- [ ] API endpoints funcionando

---

## 🆘 Resolução de Problemas

### Erro: "Application Error"
```bash
# Ver logs
railway logs  # Railway
heroku logs --tail  # Heroku
```

### Erro: "Database Connection"
1. Verificar MONGODB_URI
2. Verificar se IP está liberado no MongoDB Atlas
3. Testar conexão local

### Erro: "Assets não carregam"
```ruby
# config/environments/production.rb
config.assets.compile = true
config.serve_static_assets = true
```

### Erro: "Master Key inválida"
```bash
# Gerar nova master key
rails credentials:edit --environment production
```

---

## 💡 Dicas de Otimização

### Performance
- **Precompile assets** antes do deploy
- **Habilitar Gzip** na plataforma
- **Usar CDN** (Cloudflare gratuito)

### Monitoramento
- **Logs centralizados** via plataforma
- **Health checks** automáticos
- **Métricas de uso** no painel

### Backup
- **MongoDB Atlas** faz backup automático
- **Code backup** via Git
- **Configurações** documentadas

---

## 🎉 URLs de Exemplo

Após deploy bem-sucedido, você terá:

- **Railway**: `https://kaefer-approval.railway.app`
- **Heroku**: `https://kaefer-approval-system.herokuapp.com`
- **Render**: `https://kaefer-approval.onrender.com`

**Credenciais padrão**:
- Email: `admin@kaefer.com`
- Senha: `admin123`

---

**🚀 Recomendação**: Use **Railway** para melhor experiência gratuita, com MongoDB Atlas para banco de dados. O sistema ficará online 24/7 sem limitações de sleep!
