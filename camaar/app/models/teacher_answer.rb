# A model StudentAnswer se trata de uma entidade que representa as respostas de professores para
# questões de um formulário do sistema Camaar no banco de dados.

class TeacherAnswer < ApplicationRecord
  belongs_to :form_question
  belongs_to :teacher
end
