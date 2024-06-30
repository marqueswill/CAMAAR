# A model FormQuestion se trata de uma entidade que representa
# questões de um template do sistema Camaar no banco de dados.

class TemplateQuestion < ApplicationRecord
  has_one :template

  validates :body, presence: true
  validates :title, presence: true, allow_blank: false
  validates :question_type, presence: true, allow_blank: false
end
