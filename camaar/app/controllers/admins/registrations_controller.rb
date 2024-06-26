# Essa controladora se baseia nas funções da classe pai "Devise::RegistrationsController"
# Essencialmente, ela gerencia o registro de administradores, de forma que
# seja possível registrar um administrador para acessar o sistema Camaar

class Admins::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # POST /resource
  # Método que possibilita o registro de Administrador.
  # O método em quesstão efetuará uma chamada de serviço para AdminRegistrationService, que irá
  # enviar um email confirmando o pedido de registro de usuáario.
  def create
    super do |resource|
      AdminRegistrationService.call(resource)
    end
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
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end

  # Método que configura os parâmetros de registro
  def configure_sign_up_params
    added_attrs = %i[email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
  end
end
