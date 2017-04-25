class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :notes
      t.datetime :due
      t.integer :completion

      t.timestamps
    end
  end
end
