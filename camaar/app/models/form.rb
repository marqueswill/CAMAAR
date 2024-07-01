# A model Form se trata de uma entidade que representa um formulário do sistema Camaar no banco de dados.

class Form < ApplicationRecord
  belongs_to :coordinator
  belongs_to :subject_class
  has_many :form_question, dependent: :delete_all
end
