require 'iron_worker'
require 'open-uri'
require 'json'
require 'mongo'

class NotificationsWorker < IronWorker::Base

  merge_worker "email_worker.rb", "EmailWorker"
  
  attr_accessor :email_domain, :username, :password, :from, :mongo_port, :mongo_host, :mongo_db_name, :mongo_user,
  :mongo_password
  
  def run
    coll = init_mongo
    free = free_game
    free.each do |game|
      time = game[:time]
      home_team = game[:home_team]
      away_team = game[:away_team]
      users = coll.find("team" => {"$in" => [home_team, away_team]}).to_a
      unless users.empty?
        worker = EmailWorker.new
        worker.time = time
        worker.home_team = home_team
        worker.away_team = away_team
        worker.email_domain = email_domain
        worker.username = username
        worker.password = password
        worker.from = from
        worker.users = users
        worker.queue
      end
    end  
  end
  
  def init_mongo
    connection = Mongo::Connection.new(mongo_host, mongo_port)
    db = connection.db('mlb-notifier')
    db.authenticate(mongo_user, mongo_password)
    return db['Users']
  end

  def game_free?(media)
    media.each do |m|
      return true if m['free'] == 'ALL'
    end
    return false
  end

  def free_game  
    link = 'http://www.mlb.com/gdcross/components/game/mlb/year_' + Time.now.year.to_s + '/month_'+ Time.now.strftime("%m") + '/day_' + Time.now.strftime("%d") + '/grid.json'

    doc = JSON.parse(open(link).open.read)

    games = doc['data']['games']['game']
    free = []
    games.each do |game|
      begin
        media = game['game_media']['homebase']['media']
        if game_free?(media)
          free << {time: game['event_time'], away_team: game['away_team_name'], home_team: game['home_team_name']}
        end
      rescue Exception => e
      end
    end
    free
  end
end