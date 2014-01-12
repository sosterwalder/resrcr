class CreateSystems < ActiveRecord::Migration
  def change
    create_table :systems do |t|
      t.string :time_unit
      t.timestamps
    end
  end
end
