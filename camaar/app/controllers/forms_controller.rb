class FormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_data
  before_action :initializer
  layout "user"

  attr_reader :enrollments, :filter, :errors, :pending_forms, :answered_forms, :questions_and_answers, :subject_classes

  def initializer
    @enrollments = Enrollment.where(student_id: @student.id)
    @filter = params[:filter] || "pending"
    @errors = []
    @pending_forms = []
    @answered_forms = []
    @questions_and_answers = []
    @subject_classes = nil
  end

  def index

    occupation = current_user.occupation
    case occupation
    when "discente"
      if enrollments.empty?
        errors << "Parece que você não está matriculado em nenhum disciplina."
      else
        subject_classes = SubjectClass.where(id: enrollments.pluck(:subject_class_id))
      end
    when "docente"
      subject_classes = SubjectClass.where(teacher_id: @teacher.id)
    end

    if subject_classes.blank?
      @forms = []
      errors << "Usuário não está associado a nenhuma turma"
    else
      @forms = Form.where(subject_class_id: subject_classes.pluck(:id), role: occupation)

      @forms.each do |form|
        @form_questions = FormQuestion.where(form_id: form.id)
        form_question_ids = @form_questions.pluck(:id)
        
        answers = case occupation
                  when "discente"
                    StudentAnswer.where(form_question_id: form_question_ids)
                  when "docente"
                    TeacherAnswer.where(form_question_id: form_question_ids)
                  end
      
        if answers.any?
          answered_forms << form
        else
          pending_forms << form
        end
      end

      @forms = if filter == "pending"
                 pending_forms
               else
                 answered_forms
               end
    end
  end

  def edit
    @form = Form.find_by_id(params[:id])
    @form_questions = FormQuestion.where(form_id: @form.id)
  end

  def update; end

  def show
    @form = Form.find_by_id(params[:id])
    @form_questions = FormQuestion.where(form_id: @form.id)

    answer_model, identifier = if current_user.occupation == "discente"
                                [StudentAnswer, { student_id: @student.id }]
                              else
                                [TeacherAnswer, { teacher_id: @teacher.id }]
                              end

    @form_questions.each do |question|
      answer = answer_model.find_by(identifier.merge({ form_question_id: question.id }))
      questions_and_answers << [question, answer]
    end
  end
end
