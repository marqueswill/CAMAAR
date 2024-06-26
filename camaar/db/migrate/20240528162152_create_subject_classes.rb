class CreateSubjectClasses < ActiveRecord::Migration[7.1]
  def change
    create_table :subject_classes do |t|
      t.string :semester
      t.string :subject
      t.string :code
      t.string :name
      t.string :schedule
      t.timestamps
    end
    add_index :subject_classes, [:semester, :subject, :code], unique: true
  end
end
