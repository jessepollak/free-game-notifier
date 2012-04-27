require 'sinatra'
require 'yaml'
require 'mongo'
require 'json'

config_data = YAML.load_file('config.yml')

get '/' do
  haml :index
end

post '/contact' do
  connection = Mongo::Connection.new(config_data['mongo']['host'], config_data['mongo']['port'])
  db = connection.db('mlb-notifier')
  db.authenticate(config_data['mongo']['user'], config_data['mongo']['password'])
  coll = db['Users']
  user = {"email" => params[:email], "team" => params[:team]}
  coll.insert(user)
end