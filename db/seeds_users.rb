# Script para criar usuários iniciais no sistema

puts "🔄 Criando usuários iniciais..."

# Criar usuário admin
admin_user = User.find_or_create_by(email: 'admin@kaefer.com') do |user|
  user.name = 'Administrador KAEFER'
  user.password = 'admin123'
  user.role = 'admin'
  user.active = true
end

if admin_user.persisted?
  puts "✅ Usuário admin criado: #{admin_user.email}"
else
  puts "❌ Erro ao criar usuário admin: #{admin_user.errors.full_messages.join(', ')}"
end

# Criar usuário comum
regular_user = User.find_or_create_by(email: 'usuario@kaefer.com') do |user|
  user.name = 'Usuário KAEFER'
  user.password = 'user123'
  user.role = 'user'
  user.active = true
end

if regular_user.persisted?
  puts "✅ Usuário comum criado: #{regular_user.email}"
else
  puts "❌ Erro ao criar usuário comum: #{regular_user.errors.full_messages.join(', ')}"
end

puts "\n📊 Resumo dos usuários:"
puts "Total de usuários: #{User.count}"
puts "Administradores: #{User.admins.count}"
puts "Usuários comuns: #{User.users.count}"
puts "Usuários ativos: #{User.active.count}"

puts "\n🔑 Credenciais para teste:"
puts "Admin: admin@kaefer.com / admin123"
puts "Usuário: usuario@kaefer.com / user123"
