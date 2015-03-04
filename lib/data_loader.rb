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
    # code first
  end
  
  def add_song_to_db
    # code second
  end
  
  def add_songs_to_db
    # code third
  end

end