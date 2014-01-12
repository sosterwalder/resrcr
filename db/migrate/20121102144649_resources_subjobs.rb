class ResourcesSubjobs < ActiveRecord::Migration
  def up
    create_table :resources_subjobs do |t|
      t.references :resource
      t.references :subjob
    end
  end

  def down
    destroy_table :resources_subjobs
  end
end
