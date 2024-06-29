# Essa controladora se baseia nas funções da classe pai "Devise::SessionsController"
# Essencialmente, ela gerencia o início e o fim de sessão de administrador, de forma que
# o administrador correspondente consiga acessar o sistema Camaar

class Admins::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
