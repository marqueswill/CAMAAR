# A model Enrollment se trata de um relacionamento do sistema Camaar no banco de dados.
# Ela representa um relacionamento entre os alunos e suas respectivas classes

class Enrollment < ApplicationRecord
  belongs_to :student, optional: true
  belongs_to :subject_class, optional: true
end
