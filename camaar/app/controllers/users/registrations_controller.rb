# Essa controladora se baseia nas funções da classe pai "Devise::RegistrationsController"
# Essencialmente, ela gerencia o registro de usuários, de forma que
# seja possível registrar um usuário para acessar o sistema Camaar

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    build_resource(email: params[:user_email])
    yield resource if block_given?
    respond_with resource
  end

  # GET /resource/edit
  def edit
    render :'errors/forbidden', status: :forbidden
  end

  protected

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    added_attrs = %i[email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
  end
end
