class DataLoader

  attr_reader :data, :table_name

  def initialize(url, db, table_name)
    @data = load_json(url)
    @db = db
    @table_name = table_name
  end

  def load_json(url)
    JSON.load(open(url))
  end

  def extract_tracks
    data["tracks"]
  end

  def add_song_to_db(song_hash)
    sql = <<-SQL
    INSERT INTO songs(track_name, artist, album, url, num_streams)VALUES
    ($1, $2, $3, $4, $5)
    SQL
    parameter = [song_hash["track_name"], song_hash["artist_name"], song_hash["album_name"], song_hash["track_url"], song_hash["num_streams"]]
    @db.exec_params(sql, parameter)
  end

  def add_songs_to_db
    extract_tracks.each do |song|
      add_song_to_db(song)
    end
  end

end
