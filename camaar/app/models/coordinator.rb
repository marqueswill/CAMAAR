# A model Coordenador se trata de um coordenador do sistema Camaar no banco de dados.
# Se registrado, pode virar administrador.
# Deve estar vinculado a um departamento e administrador.

class Coordinator < ApplicationRecord
  belongs_to :department
  belongs_to :admin
  validates :email, uniqueness: true
end
