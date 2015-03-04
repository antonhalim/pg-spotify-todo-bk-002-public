require_relative '../config/environment'

RSpec.configure do |config|
  config.before(:all) do
    db = PG::Connection.open(:dbname => 'spotify', host: 'localhost')
    db.exec('DROP TABLE IF EXISTS songs');
  end
  config.after(:each) do
    db = PG::Connection.open(:dbname => 'spotify', host: 'localhost')
    db.exec('DROP TABLE IF EXISTS songs');
  end
end
