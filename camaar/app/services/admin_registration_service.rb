# Serviço responsável por mandar um email para um administrador se registrar
class AdminRegistrationService
  def self.call(admin)
    return unless admin.persisted?

    AdminsMailer.new_user_email(admin).deliver_later
  end
end
