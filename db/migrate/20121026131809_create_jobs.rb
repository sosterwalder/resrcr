class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :name
      t.datetime :earliest_starting_time
      t.datetime :latest_ending_time
      t.references :subjobs
      t.timestamps
    end
  end
end
