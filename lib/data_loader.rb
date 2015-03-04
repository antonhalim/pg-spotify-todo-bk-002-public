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
    self.data["tracks"]
  end

  def extract_values(track)
    url = track["track_url"]
    track_name = track["track_name"]
    artist = track["artist_name"]
    num_streams = track["num_streams"]
    album = track["album_name"]
    [url, track_name, artist, num_streams, album]
  end

  def make_value_string(track)
    values = extract_values(track)
    value_string = values.map{|v| "'#{v}'"}.join(",")
  end

  def execute_sql(sql_string)
    @db.exec(sql_string)
  end
  
  def add_song_to_db(track)
    insert_sql = <<-SQL
      INSERT INTO #{table_name} 
      (url, track_name, artist, num_streams, album) 
      VALUES
      (#{make_value_string(track)})
    SQL
    execute_sql(insert_sql)
  end
  
  def add_songs_to_db
    self.extract_tracks.each { |t| add_song_to_db(t) }
  end

end