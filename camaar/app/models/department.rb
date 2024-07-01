# A model Department se trata de um departamento do sistema Camaar no banco de dados.

class Department < ApplicationRecord
  validates :initials, uniqueness: true
end
