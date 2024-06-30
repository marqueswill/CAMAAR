# A model Student se trata de um aluno do sistema Camaar no banco de dados.
# Se registrado, pode virar usuário.
# Deve estar vinculado a um departamento e usuário.

class Student < ApplicationRecord
  validates :email, uniqueness: true
  validates :registration, uniqueness: true
  has_many :enrollment
  has_many :subject_class, :through => :enrollment
  belongs_to :user, optional: true
end
