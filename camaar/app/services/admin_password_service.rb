class AdminPasswordService
  # Método que possibilita a confirmação de conta caso haja algum erro durante a troca de senha.
  def self.call(resource)
    resource.send_confirmation_instructions unless resource.confirmed?
  end
end
