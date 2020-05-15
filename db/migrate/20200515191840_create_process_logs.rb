class CreateProcessLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :process_logs do |t|
      t.string :key
      t.string :status
      t.datetime :start_time
      t.datetime :end_time
      t.integer :elapsed
      t.integer :average_elapsed
      t.text :comment
      t.text :backtrace

      t.timestamps
    end
  end
end
