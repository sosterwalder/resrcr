class CreateSubjobs < ActiveRecord::Migration
  def change
    create_table :subjobs do |t|
      t.string :name
      t.integer :number_of_steps, :null => false, :default => 1
      t.references :job
      t.timestamps
    end
  end
end
