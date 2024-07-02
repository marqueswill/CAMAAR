# Classe que que representa funções de falha nativas do Devise
class CustomFailure < Devise::FailureApp
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end

  def redirect
    store_location!
    redirect_to root_path
  end
end
