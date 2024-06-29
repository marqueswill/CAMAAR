class FormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_data
  before_action :initialize_data
  layout "user"

  def index
    @forms = filtered_forms
  end

  def edit
    @form = Form.find(params[:id])
    @form_questions = @form.form_question
  end

  def update; end

  def show
    @form = Form.find(params[:id])
    @form_questions = @form.form_question
    @questions_and_answers = set_questions_and_answers
  end

  private

  attr_reader :user_service, :filter

  def initialize_data
    @user_service = user_service_for_current_user
    @filter = params[:filter] || "pending"
  end

  def user_service_for_current_user
    if current_user.discente?
      DiscenteService.new(current_user)
    elsif current_user.docente?
      DocenteService.new(current_user)
    else
      raise "Tipo de usuário não suportado"
    end
  end

  def filtered_forms
    forms = user_service.forms
    return [] if forms.empty?

    categorized_forms = categorize_forms(forms)
    filter == "pending" ? categorized_forms[:pending] : categorized_forms[:answered]
  end

  def categorize_forms(forms)
    forms.each_with_object(pending: [], answered: []) do |form, result|
      if form_answered?(form)
        puts "Form #{form.id} is answered"
        result[:answered] << form
      else
        puts "Form #{form.id} is pending"
        result[:pending] << form
      end
    end
  end
  
  def set_questions_and_answers
    @form_questions.map do |question|
      answer = user_service.find_answer(question)
      [question, answer]
    end
  end

  def form_answered?(form)
    answered = form.form_question.all? do |question|
      puts "VASCO: #{question}"
      answer = user_service.find_answer(question)
      puts "Question #{question.id} answer: #{answer.present?}"
      answer.present?
    end
    puts "Form #{form.id} overall answered status: #{answered}"
    answered
  end
end