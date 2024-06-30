# A model FormQuestion se trata de uma entidade que representa
# questões de um formulário do sistema Camaar no banco de dados.

class FormQuestion < ApplicationRecord
  has_one :form
  has_many :student_answer, dependent: :delete_all
  has_many :teacher_answer, dependent: :delete_all
end
