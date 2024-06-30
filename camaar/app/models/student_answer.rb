# A model StudentAnswer se trata de uma entidade que representa as respostas de alunos para
# questões de um formulário do sistema Camaar no banco de dados.

class StudentAnswer < ApplicationRecord
  belongs_to :form_question
  belongs_to :student
end
