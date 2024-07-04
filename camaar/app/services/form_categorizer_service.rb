# Serviço responsável por realizar a categorização de formulários
# de acordo com suas respostas (respondido ou pendente)
class FormCategorizerService
  # Método para categorizar formulários em respondidos e pendentes.
  def self.categorize(forms, user_service)
    forms.each_with_object(pending: [], answered: []) do |form, result|
      if form_answered?(form, user_service)
        result[:answered] << form
      else
        result[:pending] << form
      end
    end
  end

  # Método auxiliar para aferir se um formulário foi respondido.
  def self.form_answered?(form, user_service)
    form.form_question.all? { |question| user_service.find_answer(question).present? }
  end
end
