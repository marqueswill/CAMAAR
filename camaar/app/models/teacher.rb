# A model Teacher se trata de um professor do sistema Camaar no banco de dados.
# Se registrado, pode virar usuário.
# Deve estar vinculado a um departamento e usuário.

class Teacher < ApplicationRecord
  belongs_to :department
  belongs_to :user, optional: true
end
