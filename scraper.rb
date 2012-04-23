require 'rubygems'
require 'open-uri'
require 'json'

def game_free?(media)
  media.each do |m|
    return true if m['free'] == 'ALL'
  end
  return false
end

doc = JSON.parse(open('http://www.mlb.com/gdcross/components/game/mlb/year_2012/month_04/day_17/grid.json').open.read)

games = doc['data']['games']['game']
free = []
games.each do |game|
  media = game['game_media']['homebase']['media']
  if game_free?(media)
    free << {time: game['event_time'], away_team: game['away_team_name'], home_team: game['home_team_name']}
  end
end

puts free


    