class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.integer :amount
      t.string :payment_id
    end
  end
end
