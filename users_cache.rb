require './common'

USERS_CACHE = 'marvel-corp-users.cache'

def create_user_cache
  total = 0
  offset = 0
  users = []

  while true do
    p "GETTING USERS #{offset}"
    resp = get('characters', offset)

    page = JSON.parse(resp.body)
    total += page['data']['count'].to_i
    break if total >= page['data']['total'].to_i

    page["data"]["results"].each do |result|
      users << norm_name(result["name"])
    end
    offset += 100
  end
  users.uniq!

  File.open(USERS_CACHE, 'w') do |cache|
    users.each do |users|
      cache.puts users
    end
  end
end

unless File.exist?(USERS_CACHE)
  create_team_cache
end

@user_names = File.read(USERS_CACHE).split("\n")
