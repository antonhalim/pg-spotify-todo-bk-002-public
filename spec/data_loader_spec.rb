describe DataLoader do
  URL = "http://charts.spotify.com/api/tracks/most_streamed/us/weekly/latest"

  let(:data) { JSON.parse(File.read("spec/fixtures/data.json")) }
  let(:this_weeks_tracks) { data["tracks"] }
  let(:song_hash) { this_weeks_tracks[0] }
  let(:loaded_song) {
    {
      "track_name"=>"Love Me Like You Do - From \"Fifty Shades Of Grey\"",
      "artist"=>"Various Artists",
      "album"=>"Fifty Shades Of Grey",
      "url"=>"https://play.spotify.com/track/6iEDVsbUBGckKhuSBD3Eqf",
      "num_streams"=>"4584078"
    }
  }
  let(:uptown_funk) { this_weeks_tracks[1] }
  let(:loaded_uptown_funk) {
    {
      "track_name"=>"Uptown Funk",
      "artist"=>"Mark Ronson",
      "album"=>"Uptown Funk",
      "url"=>"https://play.spotify.com/track/4rmPQGwcLQjCoFq5NrTA0D",
      "num_streams"=>"4266789"
    }
  }
  let(:loaded_jessie_j) {
    {
      "id"=>"49",
      "track_name"=>"Bang Bang",
      "artist"=>"Jessie J",
      "album"=>"Bang Bang",
      "url"=>"https://play.spotify.com/track/2VhPOtIQw2UpQmRVevdviU",
      "num_streams"=>"1193355"
    }
  }

  before do
    @db = PG::Connection.open(:dbname => 'spotify', host: 'localhost')
    @sql_runner = SQLRunner.new(@db)
    @sql_runner.create_table
    allow_any_instance_of(DataLoader).to receive(:load_json).and_return(data)
    @loader = DataLoader.new(URL, @db, "songs")
  end
  
  describe ".new" do
    it "loads the json at the url endpoint and saves it as @data" do
      expect(@loader.instance_eval("@data")).to eq(data)
    end

    it "saves the second argument, the database, as @db" do
      expect(@loader.instance_eval("@db")).to eq(@db)
    end

    it "saves the third argument as the table name" do
      expect(@loader.instance_eval("@table_name")).to eq("songs")
    end
  end

  describe "#data" do
    it "has a reader for @data" do
      expect(@loader.data).to eq(data)
    end
  end

  describe "#table_name" do
    it "has a reader for @data" do
      expect(@loader.table_name).to eq("songs")
    end
  end

  describe "#extract_tracks" do
    it "calls on the reader for @data" do
      result = @loader.data
      expect(@loader).to receive(:data).once.and_return(result)
      @loader.extract_tracks
    end

    it "returns all the tracks in the @data hash" do
      expect(@loader.extract_tracks).to eq(this_weeks_tracks)
    end
  end

  describe "#add_song_to_db" do
    it "accepts one argument, a song hash" do
      expect { @loader.add_song_to_db(song_hash) }.to_not raise_error
    end

    it "loads the song track into the database" do
      @loader.add_song_to_db(song_hash)
      expect(@db.exec("SELECT COUNT(*) FROM songs;").first["count"]).to eq("1")
      fifty_shades_song = @db.exec("SELECT * FROM songs WHERE album='Fifty Shades Of Grey';").first
      loaded_song.each do |k, v|
        expect(fifty_shades_song[k]).to eq(v)
      end
    end

    it "doesn't hardcode the values" do
      @loader.add_song_to_db(uptown_funk)
      expect(@db.exec("SELECT COUNT(*) FROM songs;").first["count"]).to eq("1")
      uptown_funk = @db.exec("SELECT * FROM songs WHERE artist='Mark Ronson';").first
      loaded_uptown_funk.each do |k, v|
        expect(uptown_funk[k]).to eq(v)
      end
    end
  end

  describe "#add_songs_to_db" do

    it "calls on #extract_tracks" do
      result = @loader.extract_tracks
      expect(@loader).to receive(:extract_tracks).once.and_return(result)
      @loader.add_songs_to_db
    end

    it "calls on #add_song_to_db for each track" do
      expect(@loader).to receive(:add_song_to_db).exactly(51).times
      @loader.add_songs_to_db
    end

    it "adds 51 songs to the database" do
      @loader.add_songs_to_db
      expect(@db.exec("SELECT COUNT(*) FROM songs;").first["count"]).to eq("51")      
    end

    it "adds Jessie J's song Bang Bang to the songs table" do
      @loader.add_songs_to_db
      jessie_j = @db.exec("SELECT * FROM songs WHERE track_name='Bang Bang';").first
      loaded_jessie_j.each do |k, v|
        expect(jessie_j[k]).to eq(v)
      end
    end

    it "adds Mark Roson's song Uptown Funk to the songs table" do
      @loader.add_songs_to_db
      uptown_funk = @db.exec("SELECT * FROM songs WHERE artist='Mark Ronson';").first
      loaded_uptown_funk.each do |k, v|
        expect(uptown_funk[k]).to eq(v)
      end
    end

    it "adds the song from Fifty Shades of Grey to the songs table" do
      @loader.add_songs_to_db
      fifty_shades_song = @db.exec("SELECT * FROM songs WHERE album='Fifty Shades Of Grey';").first
      loaded_song.each do |k, v|
        expect(fifty_shades_song[k]).to eq(v)
      end
    end
  end
end