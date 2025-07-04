# 🔐 Variáveis de Ambiente para Deploy

## ⚡ Copie e cole no Railway/Heroku/Render

### 🔴 OBRIGATÓRIAS (Configure estas primeiro!)

```env
# Ambiente Rails
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Chave mestra Rails (COPIE DO ARQUIVO config/master.key)
RAILS_MASTER_KEY=f81b002ec2ca5dd82b519c349b41ec4c

# JWT Secret (GERE UMA NOVA CHAVE ALEATÓRIA)
JWT_SECRET=ed7683680a3f617d7ac802b3ea2454fc4eb9784e243de5dcafc2087839994526

# MongoDB Atlas (CONFIGURE DEPOIS DE CRIAR CLUSTER)
MONGODB_URI=mongodb+srv://kaefer_user:KaeferApproval2024!@kaefer-approval.i3rewq4.mongodb.net/kaefer_approval?retryWrites=true&w=majority
```

### 📧 OPCIONAIS (Email - Configure depois)

```env
# Gmail (Recomendado para teste)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-de-app-gmail
SMTP_DOMAIN=gmail.com

# Ou SendGrid (300 emails/dia grátis)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=sua-api-key-sendgrid
SMTP_DOMAIN=sendgrid.net
```

## 🎯 Como Configurar

### 1. Gerar JWT Secret
```bash
# No terminal do seu computador:
openssl rand -hex 32
# Copie o resultado para JWT_SECRET
```

### 2. MongoDB Atlas (5 min)
1. **Acesse**: https://www.mongodb.com/cloud/atlas
2. **Crie conta** (grátis)
3. **Create Cluster** → **M0 (Free)**
4. **Database Access**: Usuário `approval_user` / Senha forte
5. **Network Access**: `0.0.0.0/0` (permitir todos IPs)
6. **Connect** → **Connect application** → Copie a URI
7. **Cole em MONGODB_URI** (troque `<password>` pela sua senha)

### 3. Deploy Railway
1. **Acesse**: https://railway.app
2. **Login** com GitHub
3. **New Project** → **Deploy from GitHub repo**
4. **Variables**: Cole as variáveis acima
5. **Deploy automático** ✅

## 🚀 URLs Geradas

### Railway
- **Temporária**: `https://web-production-xxxx.up.railway.app`
- **Personalizada**: Configure domínio próprio (grátis)

### Heroku
- **Padrão**: `https://seu-app.herokuapp.com`

### Render
- **Padrão**: `https://seu-app.onrender.com`

## 🎉 Credenciais Padrão

Após o deploy, acesse com:
- **Admin**: `admin@kaefer.com` / `admin123`
- **User**: `user@kaefer.com` / `user123`

**Altere as senhas após o primeiro login!**
