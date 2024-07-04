# A classe ExportCsvService é responsável por exportar as respostas de formulários submetidos a
# discentes e/ou discentes em uma planilha de formato CSV. Ao final da execução dos serviços, será submetido
# um caminho para que seja possível efetuar a requisição do arquivo CSV.
class ExportCsvService
  # Método para chamar o serviço de exportação em CSV.
  def self.call(table)
    head = ['Questão']
    (table[0].length - 1).times do |item|
      head << "Resposta #{item + 1}"
    end
    table.unshift(head)

    generate_csv(table)
  end

  # Método para gerar um arquivo CSV a partir de uma tabela.
  def self.generate_csv(table)
    CSV.generate do |csv|
      table.each do |row|
        csv << row
      end
    end
  end

  # Método para salvar os dados CSV em um arquivo.
  def self.csv?(file_path, csv_data)
    CSV.open(file_path, 'w') do |csv|
      csv << csv_data.headers
      csv_data.each do |row|
        csv << row
      end
    end
  end

  # Método para preencher a tabela com perguntas e respostas de um formulário.
  def self.fill_table(table, form, form_questions)
    form_questions.each do |question|
      form_question_id = question.id
      answers = if form.role == 'discente'
                  StudentAnswer.where(form_question_id:)
                else
                  TeacherAnswer.where(form_question_id:)
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
