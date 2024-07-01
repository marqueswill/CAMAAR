# A model Template se trata de uma entidade que representa um template do sistema Camaar no banco de dados.

class Template < ApplicationRecord
  belongs_to :coordinator
  has_many :template_question, dependent: :delete_all
  validates :name, presence: { message: "Template precisa de um nome" }, allow_blank: false
end
