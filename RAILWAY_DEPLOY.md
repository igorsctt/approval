# 🚂 Deploy Railway - Guia Rápido

## ⚡ Deploy em 5 minutos!

### 1. MongoDB Atlas (Gratuito)
1. **Criar conta**: https://www.mongodb.com/cloud/atlas
2. **Criar cluster gratuito** (M0 Sandbox)
3. **Usuário**: `approval_user` / **Senha**: `sua-senha-forte`
4. **Network Access**: `0.0.0.0/0` (permitir de qualquer lugar)
5. **Copiar URI**: `mongodb+srv://approval_user:sua-senha@cluster0.xxxxx.mongodb.net/approval_production`

### 2. Deploy Railway
1. **Acesse**: https://railway.app
2. **Login** com GitHub
3. **New Project** → **Deploy from GitHub repo**
4. **Selecione** este repositório
5. **Railway detecta Rails automaticamente** ✅

### 3. Variáveis de Ambiente
No Railway, clique em **Variables** e adicione:

```env
# Obrigatórias
RAILS_ENV=production
MONGODB_URI=mongodb+srv://approval_user:sua-senha@cluster0.xxxxx.mongodb.net/approval_production
JWT_SECRET=sua-chave-super-secreta-de-32-caracteres-minimo
RAILS_MASTER_KEY=sua-master-key-aqui

# Opcionais (para assets)
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Email (configurar depois)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
```

### 4. Gerar Chaves
```bash
# JWT Secret (32+ caracteres)
openssl rand -hex 32

# Rails Master Key (se não tiver)
rails credentials:edit
```

### 5. Deploy Automático
- **Push para GitHub** → **Deploy automático** 🚀
- **URL gerada**: `https://seu-projeto.up.railway.app`
- **SSL automático** ✅
- **Domínio customizado** (opcional)

### 6. Pós-Deploy
- **Usuários padrão criados automaticamente**:
  - Admin: `admin@kaefer.com` / `admin123`
  - User: `user@kaefer.com` / `user123`

## 📧 Configurar Email (Opcional)

### Gmail App Password
1. **Conta Google** → **Segurança** → **Verificação em duas etapas**
2. **Senhas de app** → **Gerar senha**
3. **Usar senha gerada** em `SMTP_PASSWORD`

### Outras opções
- **SendGrid** (300 emails/dia grátis)
- **Mailgun** (100 emails/dia grátis)
- **Amazon SES** (62k emails/mês grátis)

## 🎯 Resultado Final
- ✅ Sistema online 24/7
- ✅ SSL/HTTPS automático
- ✅ MongoDB Atlas gratuito
- ✅ 500h/mês Railway (suficiente para uso contínuo)
- ✅ Deploy automático via Git
- ✅ URL personalizada disponível

**Custo total: R$ 0,00** 💰
