require './common'

TEAMS_CACHE = 'marvel-corp-teams.cache'

def create_team_cache
  total = 0
  offset = 0
  teams = []

  while true do
    p "GETTING TEAMS #{offset}"
    resp = get('comics', offset)

    page = JSON.parse(resp.body)
    total += page['data']['count'].to_i
    break if total >= page['data']['total'].to_i

    page['data']['results'].each do |sample|
      teams << norm_name(sample['title']).downcase
    end
    offset += 100
  end

  teams.uniq!

  File.open(TEAMS_CACHE, 'w') do |cache|
    teams.each do |team|
      cache.puts teams
    end
  end
end

unless File.exist?(TEAMS_CACHE)
  create_team_cache
end

@team_names = File.read(TEAMS_CACHE).split("\n")
