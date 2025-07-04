# 🚀 SISTEMA ONLINE EM 10 MINUTOS!

## 📋 Checklist Rápido

### ✅ 1. MongoDB Atlas (2 min)
- **Acesse**: https://www.mongodb.com/cloud/atlas
- **Registre-se** (grátis)
- **Create Cluster** → **M0 (Free)**
- **Username**: `kaefer_user`
- **Password**: `KaeferApproval2024!`
- **Network**: `0.0.0.0/0` (permite de qualquer lugar)
- **Copie a URI**: `mongodb+srv://kaefer_user:KaeferApproval2024!@cluster0.xxxxx.mongodb.net/kaefer_approval`

### ✅ 2. Railway Deploy (3 min)
- **Acesse**: https://railway.app
- **Login** com GitHub
- **New Project** → **Deploy from GitHub repo**
- Selecione **este repositório**
- Railway detecta Rails automaticamente ✅

### ✅ 3. Configurar Variáveis (2 min)
No Railway, clique **Variables** e cole isto:

```
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
RAILS_MASTER_KEY=f81b002ec2ca5dd82b519c349b41ec4c
JWT_SECRET=ed7683680a3f617d7ac802b3ea2454fc4eb9784e243de5dcafc2087839994526
MONGODB_URI=mongodb+srv://kaefer_user:KaeferApproval2024!@cluster0.xxxxx.mongodb.net/kaefer_approval
```

**⚠️ IMPORTANTE**: Troque `cluster0.xxxxx` pela URL real do seu MongoDB Atlas!

### ✅ 4. Deploy Automático (3 min)
- Railway faz deploy automaticamente
- Aguarde aparecer: **"Deployment Live"** ✅
- URL gerada: `https://web-production-xxxx.up.railway.app`

## 🎯 Acesso ao Sistema

### 👤 Credenciais Padrão
- **Admin**: `admin@kaefer.com` / `admin123`
- **User**: `user@kaefer.com` / `user123`

### 🔧 URLs Importantes
- **Sistema**: Sua URL do Railway
- **Saúde**: `sua-url/health` (verifica se está funcionando)
- **API**: `sua-url/api/` (documentação automática)

## 📧 Email (Opcional - Configure depois)

### Gmail (Mais fácil)
1. **Gmail** → **Conta** → **Segurança** → **Verificação em 2 etapas**
2. **Senhas de app** → Gerar senha para "Aplicativo personalizado"
3. **Adicionar no Railway**:
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=senha-gerada-pelo-gmail
```

## 🎉 RESULTADO

✅ **Sistema online 24/7**  
✅ **SSL/HTTPS automático**  
✅ **Banco MongoDB Atlas grátis**  
✅ **500h/mês Railway (suficiente para uso contínuo)**  
✅ **Deploy automático via Git**  
✅ **Custo: R$ 0,00**  

## 🆘 Problemas?

### Deploy falhou?
- Verifique se todas as variáveis estão corretas
- MongoDB URI está com senha correta?
- Logs no Railway → **Deployments** → **View Logs**

### Não consegue acessar?
- Aguarde 2-3 minutos após deploy
- Teste URL: `sua-url/health`
- Se retornar `{"status":"ok"}` = funcionando!

### Email não funciona?
- Sistema funciona sem email
- Configure depois quando precisar
