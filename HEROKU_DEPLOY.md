# 🚀 Deploy Heroku - Alternativa Mais Estável

## Por que Heroku?
- ✅ **Melhor suporte** a gems nativas (psych, nokogiri, etc.)
- ✅ **Ruby 3.4.4** totalmente suportado
- ✅ **550h/mês grátis** (suficiente para uso contínuo)
- ✅ **MongoDB Atlas** conecta perfeitamente
- ✅ **Deploy automático** via Git

## 🔧 Configuração Rápida

### 1. Instalar Heroku CLI
```bash
# Linux/Ubuntu
curl https://cli-assets.heroku.com/install.sh | sh

# Ou baixar de: https://devcenter.heroku.com/articles/heroku-cli
```

### 2. Login e Criar App
```bash
heroku login
heroku create kaefer-approval
```

### 3. Configurar Variáveis
```bash
heroku config:set RAILS_ENV=production
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set RAILS_LOG_TO_STDOUT=true
heroku config:set RAILS_MASTER_KEY=f81b002ec2ca5dd82b519c349b41ec4c
heroku config:set JWT_SECRET=ed7683680a3f617d7ac802b3ea2454fc4eb9784e243de5dcafc2087839994526
heroku config:set MONGODB_URI="mongodb+srv://kaefer_user:KaeferApproval2024!@kaefer-approval.i3rewq4.mongodb.net/kaefer_approval?retryWrites=true&w=majority"
```

### 4. Deploy
```bash
git push heroku main
```

### 5. Inicializar
```bash
heroku run rails db:seed
```

## 🎯 Resultado
**URL**: `https://kaefer-approval.herokuapp.com`

**Heroku resolve automaticamente**:
- ✅ Compilação de gems nativas
- ✅ Dependências do sistema
- ✅ Ruby 3.4.4
- ✅ Assets e build

---

**Quer tentar Heroku?** É mais confiável para gems com dependências nativas!
