# Criar usuário admin padrão se não existir
admin_email = 'admin@kaefer.com'
admin_user = User.find_by(email: admin_email)

unless admin_user
  admin_user = User.create!(
    name: 'Administrador KAEFER',
    email: admin_email,
    password: 'admin123',  # Senha temporária - deve ser alterada no primeiro login
    role: 'admin',
    active: true
  )
  
  puts "✅ Usuário admin criado:"
  puts "   Email: #{admin_user.email}"
  puts "   Senha: admin123"
  puts "   ⚠️  IMPORTANTE: Altere a senha após o primeiro login!"
else
  puts "✅ Usuário admin já existe: #{admin_user.email}"
end

# Criar usuário comum de exemplo se não existir
user_email = 'usuario@kaefer.com'
regular_user = User.find_by(email: user_email)

unless regular_user
  regular_user = User.create!(
    name: 'Usuário Exemplo',
    email: user_email,
    password: 'user123',  # Senha temporária
    role: 'user',
    active: true
  )
  
  puts "✅ Usuário comum criado:"
  puts "   Email: #{regular_user.email}"
  puts "   Senha: user123"
  puts "   ⚠️  Este é um usuário de exemplo - apenas visualização"
else
  puts "✅ Usuário comum já existe: #{regular_user.email}"
end

puts "\n🔐 CREDENCIAIS DE ACESSO:"
puts "────────────────────────────"
puts "ADMINISTRADOR:"
puts "  Email: admin@kaefer.com"
puts "  Senha: admin123"
puts "  Permissões: Criar, aprovar, rejeitar, gerenciar usuários"
puts ""
puts "USUÁRIO COMUM:"
puts "  Email: usuario@kaefer.com" 
puts "  Senha: user123"
puts "  Permissões: Apenas visualizar solicitações"
puts "────────────────────────────"
puts "⚠️  Altere essas senhas após o primeiro login!"
