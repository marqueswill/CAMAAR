class ExportCsvService
  def self.call(table)
    head = ['Questão']
    (table[0].length - 1).times do |i|
      head << "Resposta #{i + 1}"
    end
    table.unshift(head)

    CSV.generate do |csv|
      table.each do |row|
        csv << row
      end
    end
  end

  def self.csv?(file_path,csv_data)
    CSV.open(file_path, 'w') do |csv|
      csv << csv_data.headers
      csv_data.each do |row|
        csv << row
      end
    end
  end

  def self.fill_table(table, form, form_questions)
    form_questions.each do |question|
      answers = if form.role == 'discente'
                  StudentAnswer.where(form_question_id: question.id)
                else
                  TeacherAnswer.where(form_question_id: question.id)
                end

      line = [question.title]

      answers.each do |answ|
        question_body = JSON.parse(FormQuestion.find_by_id(answ.form_question_id).body)
        answer_body = JSON.parse(answ.answers)['answers']

        case question.question_type
        when 'text'
          line << answer_body
        when 'multiple_choice'
          answer_body.each do |num, selected|
            line << question_body['options'][num] if selected
          end
        end
      end
      table << line
    end
    table
  end
end
