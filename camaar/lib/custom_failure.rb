# Classe que que representa funções de falha nativas do Devise
class CustomFailure < Devise::FailureApp
  # Método para responder a uma falha de autenticação. Caso precise 
  # de autenticação HTTP, responde com autenticação HTTP.
  # Se não, redireciona pra página inicial.
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end

  # Método para redirecionar o usuário caso haja erro de autenticação.
  # Redireciona para a página inicial.
  def redirect
    store_location!
    redirect_to root_path
  end
end
