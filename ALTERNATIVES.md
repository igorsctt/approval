# Alternativas para Rodar sem MongoDB

## Opção 1: MongoDB via Docker (Recomendado)
Esta é a forma mais simples de rodar o sistema sem instalar MongoDB nativamente:

```bash
cd /home/sousaigor@MyKAEFER.com/approval-rb
sudo docker-compose up -d mongodb
bundle install
./setup.sh
rails server
```

## Opção 2: Versão SQLite (Alternativa)
Se você preferir não usar Docker, criei uma versão alternativa que usa SQLite.

### Para migrar para SQLite:

1. Execute o script de migração:
```bash
./migrate_to_sqlite.sh
```

2. Siga as instruções do README_SQLITE.md

### Diferenças da versão SQLite:
- Usa ActiveRecord ao invés de Mongoid
- Banco SQLite local (sem necessidade de Docker)
- Mantém todas as funcionalidades principais
- Mais simples para desenvolvimento local

## Opção 3: PostgreSQL (Para produção)
Para ambientes de produção, você pode facilmente adaptar para PostgreSQL:

```ruby
# No Gemfile, substitua mongoid por:
gem 'pg'
```

## Recomendação
Para desenvolvimento e testes locais:
- **MongoDB + Docker**: Mais próximo do ambiente de produção
- **SQLite**: Mais simples, sem dependências externas

Para produção:
- **MongoDB**: Melhor para dados não-estruturados e escalabilidade
- **PostgreSQL**: Melhor para dados relacionais e ACID
