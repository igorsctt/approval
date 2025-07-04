# Projeto Approval Workflow - Ruby on Rails

## Visão Geral

Este projeto é uma versão completa em Ruby on Rails do sistema de aprovação que você possui em Node.js/TypeScript. O sistema foi desenvolvido usando as tecnologias mais modernas:

### Tecnologias Utilizadas

- **Ruby**: 3.4.4
- **Rails**: 7.2
- **Database**: MongoDB com Mongoid ODM
- **Authentication**: JWT tokens
- **Styling**: TailwindCSS
- **Email**: ActionMailer com templates HTML
- **Containerização**: Docker & Docker Compose
- **Testing**: RSpec, Factory Bot, Faker
- **Caching**: Redis
- **Background Jobs**: Rake tasks para limpeza e lembretes

### Funcionalidades Implementadas

✅ **API RESTful Completa**
- Criação de solicitações de aprovação
- Validação de tokens JWT
- Aprovação/rejeição de solicitações
- Listagem de aprovações por email
- Logs de auditoria completos

✅ **Sistema de Autenticação**
- JWT tokens para aprovações
- Autenticação de usuários (opcional)
- Middleware de segurança

✅ **Sistema de Email**
- Templates HTML responsivos
- Notificações automáticas
- Lembretes de aprovação
- Notificações de expiração

✅ **Interface Web**
- Página de aprovação responsiva
- Interface moderna com TailwindCSS
- Formulários de aprovação/rejeição

✅ **Monitoramento e Logs**
- Health checks
- Logs estruturados
- Métricas de performance
- Auditoria completa

✅ **Geolocalização**
- Tracking de IP
- Informações de localização
- Logs de segurança

✅ **Containerização**
- Docker para desenvolvimento
- Docker Compose para stack completa
- Pronto para produção

### Estrutura do Projeto

```
approval-rb/
├── app/
│   ├── controllers/          # Controladores da API e Web
│   ├── models/              # Modelos Mongoid
│   ├── services/            # Lógica de negócio
│   ├── serializers/         # Serializadores para API
│   ├── mailers/             # Mailers para email
│   └── views/               # Views HTML e templates
├── config/
│   ├── environments/        # Configurações por ambiente
│   ├── initializers/        # Inicializadores
│   ├── routes.rb           # Rotas da aplicação
│   └── mongoid.yml         # Configuração MongoDB
├── lib/
│   └── tasks/              # Rake tasks customizadas
├── docker-compose.yml       # Ambiente de desenvolvimento
├── Dockerfile              # Container da aplicação
├── Gemfile                 # Dependências Ruby
└── setup.sh               # Script de instalação
```

### Como Executar

#### Opção 1: Ambiente Local

```bash
# 1. Instalar dependências
bundle install

# 2. Configurar ambiente
cp .env.example .env
# Editar .env com suas configurações

# 3. Executar setup
./setup.sh

# 4. Iniciar servidor
rails server
```

#### Opção 2: Docker (Recomendado)

```bash
# 1. Construir e executar todos os serviços
docker-compose up -d

# 2. Executar seeds
docker-compose exec app rails db:seed

# 3. Acessar aplicação
# Web: http://localhost:3000
# API: http://localhost:3000/api/v1
# Email: http://localhost:8025 (MailHog)
```

### Endpoints da API

#### Aprovações
- `POST /api/v1/approvals` - Criar nova solicitação
- `GET /api/v1/approvals` - Listar aprovações
- `GET /api/v1/approvals/validate` - Validar token
- `PUT /api/v1/approvals/approve` - Aprovar solicitação
- `PUT /api/v1/approvals/reject` - Rejeitar solicitação

#### Autenticação
- `POST /api/v1/auth/login` - Login de usuário
- `POST /api/v1/auth/validate` - Validar token de usuário

#### Saúde
- `GET /health` - Status da aplicação

### Comandos Úteis

```bash
# Limpeza de aprovações expiradas
rake approval:cleanup_expired

# Envio de lembretes
rake approval:send_reminders

# Estatísticas
rake approval:stats

# Teste de email
rake approval:test_email

# Verificação de saúde
rake approval:health_check

# Criar aprovação de exemplo
rake approval:create_sample
```

### Recursos Avançados

#### Auditoria e Logs
- Logs estruturados de todas as operações
- Tracking de geolocalização por IP
- Histórico completo de aprovações
- Métricas de performance

#### Segurança
- Validação JWT robusta
- Rate limiting (configurável)
- Headers de segurança
- Sanitização de dados

#### Escalabilidade
- Cache Redis para performance
- Otimizações de banco de dados
- Containerização para deploy
- Monitoramento integrado

### Comparação com Sistema Original

| Recurso | Node.js/TypeScript | Ruby on Rails |
|---------|-------------------|---------------|
| Linguagem | TypeScript | Ruby 3.4.4 |
| Framework | Express.js | Rails 7.2 |
| Database | MongoDB + Prisma | MongoDB + Mongoid |
| Authentication | JWT | JWT |
| Email | Nodemailer | ActionMailer |
| Styling | - | TailwindCSS |
| Testing | - | RSpec |
| Containerização | - | Docker |
| Interface Web | - | Rails Views |

### Vantagens da Versão Rails

1. **Convenção sobre Configuração**: Rails oferece estrutura padrão
2. **Ecosystem Maduro**: Gems testadas e confiáveis
3. **Interface Web Integrada**: Views e controllers nativos
4. **Ferramentas de Desenvolvimento**: Rake tasks, generators, etc.
5. **Segurança por Padrão**: Proteções built-in
6. **Escalabilidade**: Padrões estabelecidos para crescimento

### Próximos Passos

1. **Configurar Variáveis de Ambiente**: Editar `.env` com suas configurações
2. **Personalizar Templates**: Adaptar emails e interface
3. **Configurar Deploy**: Usar Docker ou plataforma como Heroku
4. **Implementar Testes**: Adicionar testes específicos do seu domínio
5. **Monitoramento**: Configurar APM e alertas

### Suporte

O sistema está completo e funcional, incluindo:
- Documentação completa
- Scripts de setup automatizados
- Testes básicos de API
- Configuração de Docker
- Templates de email
- Interface web responsiva

Todos os arquivos foram criados e estão prontos para uso. Execute o script `./setup.sh` para começar!
