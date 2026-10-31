# Sample migration backing the `Employee` model. Generate further ones with
# `rake db:generate:migration NAME`.
class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table(:employees) do |t|
      t.string(:name, null: false)
      t.string(:email)
      t.timestamps
    end
  end
end
