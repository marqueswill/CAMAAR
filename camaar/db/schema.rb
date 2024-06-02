# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_02_011659) do
  create_table "coordinators", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "department_id", null: false
    t.index ["department_id"], name: "index_coordinators_on_department_id"
    t.index ["email"], name: "index_coordinators_on_email", unique: true
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "initials"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["initials"], name: "index_departments_on_initials", unique: true
  end

  create_table "enrollments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "student_id", null: false
    t.integer "subject_classes_id", null: false
    t.index ["student_id"], name: "index_enrollments_on_student_id"
    t.index ["subject_classes_id"], name: "index_enrollments_on_subject_classes_id"
  end

  create_table "forms", force: :cascade do |t|
    t.json "questions"
    t.string "role", default: "student"
    t.boolean "open", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "template_id", null: false
    t.index ["template_id"], name: "index_forms_on_template_id"
  end

  create_table "student_answers", force: :cascade do |t|
    t.json "answers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "form_id", null: false
    t.integer "student_id", null: false
    t.index ["form_id"], name: "index_student_answers_on_form_id"
    t.index ["student_id"], name: "index_student_answers_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.integer "registration"
    t.string "name"
    t.string "course"
    t.string "formation"
    t.string "occupation"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["registration"], name: "index_students_on_registration", unique: true
  end

  create_table "subject_classes", force: :cascade do |t|
    t.string "semester"
    t.string "subject"
    t.string "code"
    t.string "name"
    t.string "schedule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "department_id", null: false
    t.integer "teacher_id"
    t.index ["department_id"], name: "index_subject_classes_on_department_id"
    t.index ["semester", "subject", "code"], name: "index_subject_classes_on_semester_and_subject_and_code", unique: true
    t.index ["teacher_id"], name: "index_subject_classes_on_teacher_id"
  end

  create_table "teacher_answers", force: :cascade do |t|
    t.json "answers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "form_id", null: false
    t.integer "teacher_id", null: false
    t.index ["form_id"], name: "index_teacher_answers_on_form_id"
    t.index ["teacher_id"], name: "index_teacher_answers_on_teacher_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.integer "registration"
    t.string "name"
    t.string "formation"
    t.string "occupation"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "department_id", null: false
    t.index ["department_id"], name: "index_teachers_on_department_id"
    t.index ["email"], name: "index_teachers_on_email", unique: true
    t.index ["registration"], name: "index_teachers_on_registration", unique: true
  end

  create_table "templates", force: :cascade do |t|
    t.string "name"
    t.json "questions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "coordinator_id", null: false
    t.index ["coordinator_id"], name: "index_templates_on_coordinator_id"
  end

  add_foreign_key "coordinators", "departments"
  add_foreign_key "enrollments", "students"
  add_foreign_key "enrollments", "subject_classes", column: "subject_classes_id"
  add_foreign_key "forms", "templates"
  add_foreign_key "student_answers", "forms"
  add_foreign_key "student_answers", "students"
  add_foreign_key "subject_classes", "departments"
  add_foreign_key "subject_classes", "teachers"
  add_foreign_key "teacher_answers", "forms"
  add_foreign_key "teacher_answers", "teachers"
  add_foreign_key "teachers", "departments"
  add_foreign_key "templates", "coordinators"
ActiveRecord::Schema[7.1].define(version: 2024_05_29_111804) do
  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", limit: 50
    t.string "course", limit: 50
    t.integer "registration"
    t.integer "user"
    t.string "formation", limit: 50
    t.string "occupation", limit: 50
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
