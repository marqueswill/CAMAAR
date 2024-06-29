class TemplateQuestion < ApplicationRecord
  has_one :template

  validates :body, presence: true
  validates :title, presence: true, allow_blank: false
  validates :question_type, presence: true, allow_blank: false
end
