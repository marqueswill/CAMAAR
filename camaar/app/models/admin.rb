# A model Admin é uma entidade responsável por acessar o sistema Camaar.
# Ela herda os parâmetros do devise e os demais atributos necessários para manter
# a integridade com as demais entidades do banco de dados
# Se trata de um coordenador.

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

end
