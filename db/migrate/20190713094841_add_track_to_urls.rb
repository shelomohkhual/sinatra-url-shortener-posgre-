class AddTrackToUrls < ActiveRecord::Migration[5.2]
  def change
    add_column :urls, :track, :integer
  endw
end
