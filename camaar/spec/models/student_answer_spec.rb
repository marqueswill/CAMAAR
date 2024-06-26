require 'rails_helper'

RSpec.describe StudentAnswer, type: :model do
  it 'é válido com atributos válidos e FKS existentes' do
    department = create(:department, :departament1)

    admin = create(:admin, :admin1)

    user1 = create(:user, :user1)
    user2 = create(:user, :user2)
    user3 = create(:user, :user3)
    user4 = create(:user, :user4)
    user5 = create(:user, :user5)

    student1 = create(:student, :student1)
    student2 = create(:student, :student2)
    student3 = create(:student, :student3)
    student4 = create(:student, :student4)

    coordinator = create(:coordinator, :coordinator1)
    template = create(:template, :template1)
    template_questions = create(:template_question, :template_question1)
    teacher = create(:teacher, :teacher1)

    subject_class1 = create(:subject_class, :subject_class1)

    form = create(:form, :form1)
    form_question = create(:form_question, :form_question1)

    answ1 = create(:student_answer, :student_answers1)
    answ2 = create(:student_answer, :student_answers2)
    answ3 = create(:student_answer, :student_answers3)

    expect(answ1).to be_valid
    expect(answ2).to be_valid
    expect(answ3).to be_valid
  end

  it 'é inválido sem FKS existentes' do
    students_answer = build(:student_answer)
    expect(students_answer).to_not be_valid
  end
end
