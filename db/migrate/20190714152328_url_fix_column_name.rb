class UrlFixColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :urls, :track, :freq
  end
end
