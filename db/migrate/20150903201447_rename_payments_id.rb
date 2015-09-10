class RenamePaymentsId < ActiveRecord::Migration
  def change
    rename_column :payments, :payment_id, :token
  end
end
