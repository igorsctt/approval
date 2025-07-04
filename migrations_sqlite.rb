# Migrations para SQLite
# Execute estes comandos após ./migrate_to_sqlite.sh

# 1. Gerar as migrations
rails generate migration CreateApprovals email:string:index description:text action_id:string:index callback_url:string status:string:index signature:string expire_at:datetime processed_at:datetime ip_address:string user_agent:text location:string

rails generate migration CreateApprovalLogs approval:references action:string:index ip_address:string user_agent:text location:string details:text

rails generate migration CreateUsers email:string:uniq name:string password_digest:string role:string:index

# 2. Edite as migrations geradas para adicionar:

# db/migrate/xxx_create_approvals.rb
class CreateApprovals < ActiveRecord::Migration[7.2]
  def change
    create_table :approvals do |t|
      t.string :email, null: false
      t.text :description, null: false
      t.string :action_id, null: false
      t.string :callback_url, null: false
      t.string :status, default: 'created'
      t.string :signature
      t.datetime :expire_at
      t.datetime :processed_at
      t.string :ip_address
      t.text :user_agent
      t.string :location

      t.timestamps
    end

    add_index :approvals, :email
    add_index :approvals, :action_id
    add_index :approvals, :status
    add_index :approvals, :expire_at
    add_index :approvals, :created_at
  end
end

# db/migrate/xxx_create_approval_logs.rb
class CreateApprovalLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :approval_logs do |t|
      t.references :approval, null: false, foreign_key: true
      t.string :action, null: false
      t.string :ip_address, null: false
      t.text :user_agent
      t.string :location
      t.text :details

      t.timestamps
    end

    add_index :approval_logs, :action
    add_index :approval_logs, :created_at
  end
end

# db/migrate/xxx_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :password_digest, null: false
      t.string :role, default: 'user'

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
