class AddSchema < ActiveRecord::Migration[5.0]
  def change
    enable_extension "plpgsql"
    enable_extension "uuid-ossp"

    create_table :users, id: :uuid do |t|
      t.string   "enc_github_token"
      t.string   "enc_heroku_token"
      t.string   "enc_heroku_refresh_token"
      t.string   "heroku_uuid"
      t.string   "heroku_email"
      t.datetime "heroku_expires_at"
      t.string   "slack_user_id",     null: false
      t.string   "slack_user_name",   null: false
      t.string   "slack_team_id",     null: false
      t.timestamps
    end

    create_table :commands, id: :uuid do |t|
      t.string "args",           null: true
      t.string "application",    null: true
      t.string "channel_id",     null: false
      t.string "channel_name",   null: false
      t.string "command",        null: false
      t.string "command_text",   null: true
      t.string "response_url",   null: false
      t.string "subtask",        null: true
      t.string "task",           null: true
      t.string "team_id",        null: false
      t.string "team_domain",    null: false
      t.uuid   "user_id",        null: false
      t.datetime "processed_at", null: true
      t.timestamps
    end

    add_foreign_key :commands, :users
  end
end
