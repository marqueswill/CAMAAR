# Essa controladora se baseia nas funções da classe pai "Devise::RegistrationsController"
# Essencialmente, ela gerencia o registro de administradores, de forma que
# seja possível registrar um administrador para acessar o sistema Camaar

class Admins::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # POST /resource
  def create
    super do |resource|
      AdminRegistrationService.call(resource)
    end
  end

  # GET /resource/edit
  def edit
    render :'errors/forbidden', status: :forbidden
  end

  protected

  def sign_up_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end

  #
  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    added_attrs = %i[email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
  end
end
