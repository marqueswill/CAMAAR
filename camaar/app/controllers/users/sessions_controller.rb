# Essa controladora se baseia nas funções da classe pai "Devise::SessionsController"
# Essencialmente, ela gerencia o início e o fim de sessão de usuário, de forma que
# o usuário correspondente consiga acessar o sistema Camaar

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    added_attrs = %i[email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit(:sign_in, keys: added_attrs)
  end
end
