# Essa controladora se baseia nas funções da classe pai "Devise::PasswordsController"
# Essencialmente, ela gerencia a troca de senhas, de forma que
# o administrador correspondente consiga trocar sua senha e posteriormente acessar o sistema Camaar

class Admins::PasswordsController < Devise::PasswordsController
  # PUT /resource/password
  # Método que possibilita que o administrador atualize sua senha, efetuando uma requisição PUT
  # Caso não haja erro, será confirmado pela execução do método admin_password_service
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      admin_password_service(resource)
    else
      respond_with resource
    end
  end

  protected

  # Método que possibilita a confirmação de conta caso haja algum erro durante a troca de senha.
  def admin_password_service(resource)
    resource.unlock_access! if unlockable?(resource)
    resource.send_confirmation_instructions unless resource.confirmed?
    admin_reseting_service(resource)
  end
  # método que possibilita a visualização de flash alerts caso seja efetuada a troca de senha/autenticação
  def admin_reseting_service(resource)
    flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
    set_flash_message(:notice, flash_message) if is_navigational_format?
    respond_with resource, location: after_resetting_password_path_for(resource)
  end
end
