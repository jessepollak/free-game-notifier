require 'rubygems'
require 'open-uri'
require 'json'

def game_free?(media)
  media.each do |m|
    return true if m['free'] == 'ALL'
  end
  return false
end

link = 'http://www.mlb.com/gdcross/components/game/mlb/year_' + Time.now.year.to_s + '/month_'+ Time.now.strftime("%m") + '/day_' + Time.now.strftime("%d") + '/grid.json'

puts link
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

puts free


    