ActiveRecord::Schema.define :version => 0 do
  create_table :documents do |t|
    t.column :title, :string, :null => false
    t.column :description, :text
    t.column :filename, :string, :null => false
    t.column :content_type, :string, :null => false
    t.column :size, :integer, :null => false
    t.column :created_at, :datetime, :null => false
    t.column :updated_at, :datetime, :null => false
  end
end
