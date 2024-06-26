# Essa controladora se baseia nas funções da classe pai "Devise::RegistrationsController"
# Essencialmente, ela gerencia o registro de usuários, de forma que
# seja possível registrar um usuário para acessar o sistema Camaar

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # Método que possibilita o registro de usuário.
  # A página de registro , por meio do método build_resource, virá com um email exato
  # do usuário solicitante de registro, cabendo a este definir somente a senha.
  def new
    build_resource(email: params[:user_email])
    yield resource if block_given?
    respond_with resource
  end

  # Método proibido.
  # O método em questão é herdado pela controladora do devise, mas proibido em nosso sistema,
  # retornando um http status :forbidden e renderizando uma tela de erro.
  def edit
    render :'errors/forbidden', status: :forbidden
  end

  protected
  # Método que solicita o requerimento dos parâmetros de registro
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  # Método que configura os parâmetros de registro
  def configure_sign_up_params
    added_attrs = %i[email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
  end
end
