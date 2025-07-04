# Guia de Deploy - Sistema de Aprovação KAEFER

## 🚀 Deploy em Produção

### Pré-requisitos
- Servidor Linux (Ubuntu 20.04+ recomendado)
- Ruby 3.4.4
- MongoDB 4.4+
- Nginx (proxy reverso)
- SSL/TLS certificado

### 1. Preparação do Servidor

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências
sudo apt install -y curl git build-essential libssl-dev libreadline-dev zlib1g-dev

# Instalar rbenv e Ruby
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Instalar ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Instalar Ruby 3.4.4
rbenv install 3.4.4
rbenv global 3.4.4

# Instalar Bundler
gem install bundler
```

### 2. Instalação do MongoDB

```bash
# Importar chave pública
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

# Adicionar repositório
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

# Instalar MongoDB
sudo apt update
sudo apt install -y mongodb-org

# Iniciar serviço
sudo systemctl start mongod
sudo systemctl enable mongod
```

### 3. Clone e Configuração do Projeto

```bash
# Clone do repositório
git clone <repository-url> /var/www/approval-kaefer
cd /var/www/approval-kaefer

# Instalar gems
bundle install --deployment --without development test

# Configurar variáveis de ambiente
cp .env.example .env.production
```

### 4. Configuração de Ambiente (.env.production)

```env
# Banco de Dados
MONGODB_URI=mongodb://localhost:27017/approval_workflow_production

# Rails
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Segurança
JWT_SECRET=sua-chave-jwt-super-secreta-de-32-caracteres-ou-mais
RAILS_MASTER_KEY=sua-master-key-do-credentials

# SSL/HTTPS
FORCE_SSL=true

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=sistema@kaefer.com
SMTP_PASSWORD=sua-senha-de-app
SMTP_DOMAIN=kaefer.com

# URLs
APPROVAL_URL=https://aprovacoes.kaefer.com
```

### 5. Preparação da Aplicação

```bash
# Precompilar assets
RAILS_ENV=production bundle exec rails assets:precompile

# Configurar permissões
sudo chown -R deploy:deploy /var/www/approval-kaefer
sudo chmod -R 755 /var/www/approval-kaefer

# Criar usuários iniciais
RAILS_ENV=production ruby create_users.rb
```

### 6. Configuração do Nginx

```nginx
# /etc/nginx/sites-available/approval-kaefer
upstream puma {
  server unix:///var/www/approval-kaefer/shared/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name aprovacoes.kaefer.com;
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name aprovacoes.kaefer.com;

  root /var/www/approval-kaefer/public;
  access_log /var/log/nginx/approval-kaefer_access.log;
  error_log /var/log/nginx/approval-kaefer_error.log info;

  # SSL Configuration
  ssl_certificate /etc/letsencrypt/live/aprovacoes.kaefer.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/aprovacoes.kaefer.com/privkey.pem;
  
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
  ssl_prefer_server_ciphers off;

  # Security Headers
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-XSS-Protection "1; mode=block" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer-when-downgrade" always;
  add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

  # Gzip Compression
  gzip on;
  gzip_vary on;
  gzip_min_length 1024;
  gzip_proxied expired no-cache no-store private must-revalidate auth;
  gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

  location ^~ /assets/ {
    gzip_static on;
    expires 1y;
    add_header Cache-Control public;
    add_header Last-Modified "";
    add_header ETag "";
    break;
  }

  try_files $uri/index.html $uri @puma;
  
  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

### 7. Configuração do Puma

```ruby
# config/puma.rb
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RAILS_ENV'] || 'development'

on_worker_boot do
  # Worker específico setup para Mongoid
  Mongoid.load!(Rails.root.join('config', 'mongoid.yml'), Rails.env)
end

# Permite reinicialização
plugin :tmp_restart
```

### 8. Service do Systemd

```ini
# /etc/systemd/system/puma-approval.service
[Unit]
Description=Puma HTTP Server - Approval KAEFER
After=network.target

[Service]
Type=notify
User=deploy
WorkingDirectory=/var/www/approval-kaefer
Environment=RAILS_ENV=production
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
ExecReload=/bin/kill -SIGUSR1 $MAINPID
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=5
PrivateTmp=true
Restart=always
RestartSec=1
StartLimitBurst=3
StartLimitInterval=60

[Install]
WantedBy=multi-user.target
```

### 9. Ativação dos Serviços

```bash
# Ativar site no Nginx
sudo ln -s /etc/nginx/sites-available/approval-kaefer /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Ativar serviço Puma
sudo systemctl daemon-reload
sudo systemctl enable puma-approval
sudo systemctl start puma-approval
sudo systemctl status puma-approval
```

### 10. SSL com Let's Encrypt

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d aprovacoes.kaefer.com

# Renovação automática
sudo crontab -e
# Adicionar linha:
0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔧 Configuração de Monitoramento

### Logs Centralizados

```bash
# Configurar logrotate
sudo tee /etc/logrotate.d/approval-kaefer << EOF
/var/www/approval-kaefer/log/*.log {
  daily
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  create 644 deploy deploy
  postrotate
    systemctl reload puma-approval
  endscript
}
EOF
```

### Health Check Script

```bash
#!/bin/bash
# /usr/local/bin/approval-health-check.sh

URL="https://aprovacoes.kaefer.com/health"
EXPECTED="healthy"

response=$(curl -s $URL | jq -r '.status' 2>/dev/null)

if [ "$response" != "$EXPECTED" ]; then
    echo "$(date): Health check failed - Response: $response" >> /var/log/approval-health.log
    # Opcional: enviar alerta por email
    # echo "Sistema de aprovação KAEFER com problema" | mail -s "Alert" admin@kaefer.com
fi
```

### Cron Job para Health Check

```bash
# Adicionar ao crontab
*/5 * * * * /usr/local/bin/approval-health-check.sh
```

## 📊 Backup e Recuperação

### Script de Backup MongoDB

```bash
#!/bin/bash
# /usr/local/bin/backup-approval.sh

BACKUP_DIR="/backup/approval-kaefer"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
DB_NAME="approval_workflow_production"

# Criar diretório de backup
mkdir -p $BACKUP_DIR

# Backup MongoDB
mongodump --db $DB_NAME --out $BACKUP_DIR/$DATE/

# Compactar backup
tar -czf $BACKUP_DIR/approval-$DATE.tar.gz -C $BACKUP_DIR $DATE/
rm -rf $BACKUP_DIR/$DATE/

# Manter apenas últimos 30 backups
find $BACKUP_DIR -name "approval-*.tar.gz" -mtime +30 -delete

echo "Backup concluído: approval-$DATE.tar.gz"
```

### Backup Automático

```bash
# Adicionar ao crontab (backup diário às 2:00)
0 2 * * * /usr/local/bin/backup-approval.sh
```

### Restauração

```bash
# Restaurar backup específico
tar -xzf /backup/approval-kaefer/approval-2024-12-15_02-00-00.tar.gz -C /tmp/
mongorestore --db approval_workflow_production /tmp/2024-12-15_02-00-00/approval_workflow_production/
```

## 🚀 Deploy Automatizado (CI/CD)

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Deploy to server
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          cd /var/www/approval-kaefer
          git pull origin main
          bundle install --deployment
          RAILS_ENV=production bundle exec rails assets:precompile
          sudo systemctl restart puma-approval
```

## 🔒 Segurança em Produção

### Firewall (UFW)

```bash
# Configurar firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

### Fail2Ban

```bash
# Instalar e configurar
sudo apt install fail2ban

# Configurar para Nginx
sudo tee /etc/fail2ban/jail.local << EOF
[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3
bantime = 3600

[nginx-dos]
enabled = true
filter = nginx-dos
logpath = /var/log/nginx/access.log
maxretry = 10
findtime = 60
bantime = 3600
EOF

sudo systemctl restart fail2ban
```

## 📈 Otimização de Performance

### Configuração MongoDB

```javascript
// Conectar ao MongoDB e executar:
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "role": 1 })
db.approvals.createIndex({ "action_id": 1 }, { unique: true })
db.approvals.createIndex({ "status": 1 })
db.approvals.createIndex({ "created_at": -1 })
db.approval_logs.createIndex({ "approval_id": 1 })
```

### Configuração de Memória

```ruby
# config/environments/production.rb
config.cache_store = :memory_store, { size: 64.megabytes }
config.active_record.query_cache_enabled = true
```

---

Este guia de deploy fornece uma configuração robusta e segura para produção. Ajuste as configurações conforme necessário para seu ambiente específico.
