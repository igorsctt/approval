#!/bin/bash
# Railway specific build script

set -e

echo "🔧 Railway Build - Sistema KAEFER"

# Install dependencies
echo "📥 Instalando gems..."
bundle install --without development:test

# Precompile assets
echo "🎨 Compilando assets..."
RAILS_ENV=production bundle exec rails assets:precompile

echo "✅ Build concluído com sucesso!"
