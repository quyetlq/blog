class ChangeColumnName < ActiveRecord::Migration[5.1]
  def change
  	rename_column :comments, :comment_id, :reply_comment_id
  end
end
