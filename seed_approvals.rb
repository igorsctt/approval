#!/usr/bin/env ruby
# Script para criar mais solicitações de aprovação

puts 'Criando mais solicitações de aprovação...'

# Conectar ao Rails
require_relative 'config/environment'

# Criar 10 novas solicitações
requests = [
  {
    description: 'Solicitação de compra de equipamentos de TI - Notebooks Dell',
    requested_by: 'Ana Silva',
    requested_by_email: 'ana.silva@kaefer.com',
    amount: 15000.00,
    category: 'TI',
    priority: 'high',
    action_id: 'TI-0101-01'
  },
  {
    description: 'Contratação de serviços de consultoria externa - Projeto Alpha',
    requested_by: 'Carlos Santos',
    requested_by_email: 'carlos.santos@kaefer.com',
    amount: 25000.00,
    category: 'Consultoria',
    priority: 'medium',
    action_id: 'CONS-0101-02'
  },
  {
    description: 'Renovação de licenças de software - Microsoft Office',
    requested_by: 'Maria José',
    requested_by_email: 'maria.jose@kaefer.com',
    amount: 8000.00,
    category: 'Software',
    priority: 'low',
    action_id: 'SOFT-0101-03'
  },
  {
    description: 'Viagem de negócios - Conferência Internacional',
    requested_by: 'João Pedro',
    requested_by_email: 'joao.pedro@kaefer.com',
    amount: 12000.00,
    category: 'Viagem',
    priority: 'medium',
    action_id: 'VIAG-0101-04'
  },
  {
    description: 'Aquisição de materiais de construção - Projeto Beta',
    requested_by: 'Roberto Lima',
    requested_by_email: 'roberto.lima@kaefer.com',
    amount: 45000.00,
    category: 'Materiais',
    priority: 'high',
    action_id: 'MAT-0101-05'
  },
  {
    description: 'Treinamento de equipe - Certificação em Segurança',
    requested_by: 'Fernanda Costa',
    requested_by_email: 'fernanda.costa@kaefer.com',
    amount: 18000.00,
    category: 'Treinamento',
    priority: 'medium',
    action_id: 'TREI-0101-06'
  },
  {
    description: 'Manutenção preventiva de equipamentos industriais',
    requested_by: 'Ricardo Oliveira',
    requested_by_email: 'ricardo.oliveira@kaefer.com',
    amount: 22000.00,
    category: 'Manutenção',
    priority: 'high',
    action_id: 'MANUT-0101-07'
  },
  {
    description: 'Compra de uniformes e EPIs para equipe de campo',
    requested_by: 'Luciana Mendes',
    requested_by_email: 'luciana.mendes@kaefer.com',
    amount: 9500.00,
    category: 'Segurança',
    priority: 'medium',
    action_id: 'SEG-0101-08'
  },
  {
    description: 'Contratação de serviços de limpeza e conservação',
    requested_by: 'Paulo Henrique',
    requested_by_email: 'paulo.henrique@kaefer.com',
    amount: 6000.00,
    category: 'Serviços',
    priority: 'low',
    action_id: 'SERV-0101-09'
  },
  {
    description: 'Upgrade de infraestrutura de rede - Switches e Roteadores',
    requested_by: 'Amanda Rodrigues',
    requested_by_email: 'amanda.rodrigues@kaefer.com',
    amount: 35000.00,
    category: 'Infraestrutura',
    priority: 'high',
    action_id: 'INFRA-0101-10'
  }
]

requests.each_with_index do |req, index|
  approval = Approval.create!(
    description: req[:description],
    requested_by: req[:requested_by],
    requested_by_email: req[:requested_by_email],
    amount: req[:amount],
    category: req[:category],
    priority: req[:priority],
    action_id: req[:action_id],
    status: 'pending',
    created_at: Time.current - (index * 2).hours
  )
  
  puts "Criada solicitação: #{approval.action_id} - #{approval.description[0..50]}..."
end

puts "\n#{Approval.count} solicitações de aprovação no total"
puts "#{Approval.where(status: 'pending').count} solicitações pendentes"
