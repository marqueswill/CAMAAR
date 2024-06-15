require 'rails_helper'

RSpec.describe TeacherAnswer, type: :model do
  it 'é válido com atributos válidos e FKS existentes' do
    department = create(:department, :departament1)

    admin = create(:admin, :admin1)

    user1 = create(:user, :user1)
    user2 = create(:user, :user2)
    user3 = create(:user, :user3)
    user4 = create(:user, :user4)
    user5 = create(:user, :user5)

    coordinator = create(:coordinator, :coordinator1)
    template = create(:template)
    template_questions = create(:template_question)
    teacher = create(:teacher)

    subject_class1 = create(:subject_class)

    form = create(:form)
    form_question = create(:form_question)

    answer = create(:teacher_answer, :teacher_answers1)

    expect(answer).to be_valid
  end

  it 'é inválido sem FKS existentes' do
    teacher_answers = build(:teacher_answer)
    expect(teacher_answers).to_not be_valid
  end
end
