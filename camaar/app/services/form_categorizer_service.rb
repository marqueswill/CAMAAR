class FormCategorizerService
    def self.categorize(forms, user_service)
      forms.each_with_object(pending: [], answered: []) do |form, result|
        if form_answered?(form, user_service)
          result[:answered] << form
        else
          result[:pending] << form
        end
      end
    end
  
    def self.form_answered?(form, user_service)
      form.form_question.all? { |question| user_service.find_answer(question).present? }
    end
  end