class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |f|
      f.string :username
      f.string :email
      f.string :password

      f.timestamps null: false
    end
  end
end
