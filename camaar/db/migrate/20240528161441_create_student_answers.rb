class CreateStudentAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :student_answers do |t|
      # t.string :question_type
      t.json :answers

      t.timestamps
    end
  end
end
