# A model SubjectClass se trata de uma entidade do sistema Camaar no banco de dados.
# Ela representa uma turma que possui alunos e um professor.

class SubjectClass < ApplicationRecord
  belongs_to :department
  has_one :teacher

  has_many :enrollment
  has_many :student, :through => :enrollment
end
