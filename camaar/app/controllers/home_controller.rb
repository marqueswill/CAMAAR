# A classe HomeController é uma controller base do rails e gerencia as requisições
# na raiz do projeto ("/")
class HomeController < ApplicationController
  before_action :logout, only: :index

  # Método para exibir a página inicial.
  def index; end

  private

  # Método para fazer logout de admin ou user.
  def logout
    if admin_signed_in?
      sign_out(current_admin) # Faz logout do usuário
    elsif user_signed_in?
      sign_out(current_user)
    end
  end
end
