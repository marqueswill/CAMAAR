require 'json'

# A classe UsersController gerencia as principais ações relacionadas às funcionalidades do usuário.
# Essa classe inclui a possibilidade de responder formulários e visualizar suas respostas.

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_data
  layout 'user'

  def index; end

  def new; end

  def create; end

  def show
    check_for_commit
  end

  def edit;  end

  def update; end

  def page; end

  def destroy; end

end
