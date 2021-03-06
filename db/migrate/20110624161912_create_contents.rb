class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.references :user
      t.references  :related_content

      t.string   :type
      t.string   :tags
      t.datetime :published_at
      t.boolean  :moderated, :default => false
      t.boolean  :rejected, :default => false
      t.datetime :moderated_at
      t.string   :location
      t.float    :latitude
      t.float    :longitude

      t.string   :external_id

      t.string  :slug

      t.integer :comments_count, :default => 0
      t.integer :answer_requests_count, :default => 0

      t.timestamps
    end

    add_index :contents, [:id, :type]
    add_index :contents, [:id, :type, :moderated]
    add_index :contents, [:id, :published_at, :type ]
    add_index :contents, [:slug, :type],              :unique => true

  end

  def self.down
    drop_table :contents
  end
end
