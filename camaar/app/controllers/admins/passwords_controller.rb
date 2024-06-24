# Essa controladora se baseia nas funções da classe pai "Devise::PasswordsController"
# Essencialmente, ela gerencia a troca de senhas, de forma que
# o administrador correspondente consiga trocar sua senha e posteriormente acessar o sistema Camaar

class Admins::PasswordsController < Devise::PasswordsController
  # PUT /resource/password
  # override this so admin isn't signed in after resetting password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      admin_password_service(resource)
    else
      respond_with resource
    end
  end

  protected

  def admin_password_service(resource)
    resource.unlock_access! if unlockable?(resource)
    resource.send_confirmation_instructions unless resource.confirmed?
    admin_reseting_service(resource)
  end

  def admin_reseting_service(resource)
    flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
    set_flash_message(:notice, flash_message) if is_navigational_format?
    respond_with resource, location: after_resetting_password_path_for(resource)
  end
end
