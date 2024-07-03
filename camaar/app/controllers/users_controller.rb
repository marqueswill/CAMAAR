require 'json'

# A classe UsersController gerencia as principais ações relacionadas às funcionalidades do usuário.
# Essa classe inclui a possibilidade de responder formulários e visualizar suas respostas.
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_data
  layout 'user'

  # Método default do Rails para executar GET index
  def index; end

  # Método default do Rails para executar GET new.
  def new; end

  # Método para criar um usuário.
  def create; end

  # Método para exibir detalhes de um usuário e verificar seus commits.
  def show
    check_for_commit
  end

  # Método default do Rails para executar GET edit.
  def edit; end

  # Método para atualizar detalhes de um usuário.
  def update; end

  # Método para exibir uma página específica ao usuário.
  def page; end

  # Método para deletar um usuário.
  def destroy; end
end
