class EmailTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :email_templates, force: :cascade do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :subject
      t.string :body
      t.boolean :is_html, default: false
      t.timestamps
    end
  end
end
