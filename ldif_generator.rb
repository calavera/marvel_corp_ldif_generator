#{
#  "code": 200,
#  "status": "Ok",
#  "etag": "b5abc51971018bd6e2dfe0ee9e9f72114ffb4e6a",
#  "data": {
#    "offset": 0,
#    "limit": 100,
#    "total": 1402,
#    "count": 100,
#    "results": [
#      {
#        "id": 1009521,
#        "name": " Hank Pym",
#        "description": "",
#        "modified": "1969-12-31T19:00:00-0500",
#        "thumbnail": {
#          "path": "http://i.annihil.us/u/prod/marvel/i/mg/8/c0/4ce5a0e31f109",
#          "extension": "jpg"
#        }
#     ...
#   ]
# }
#}

require './common'
require './users_cache'
require './teams_cache'

users = @user_names.map do |name|
  login = slug(name)
  {
    :dn           => "uid=#{login},ou=users,dc=marvel-corp,dc=com",
    :cn           => name,
    :sn           => name,
    :uid          => login,
    :userPassword => 'passworD1',
    :mail         => "#{login}@marvel-corp.com",
    :objectClass  => 'inetOrgPerson'
  }
end

teams = @team_names.sample(7000).map do |name|
  {
    dn: "cn=#{name},ou=groups,dc=marvel-corp,dc=com",
    cn: name,
    objectClass: 'groupOfNames',
    member: users.sample(rand(20..40)).map{|u| u[:dn]}
  }
end

#5.times do
#  teams.sample(5000).each do |team|
#    teams.sample(rand(0..10)).each do |subteam|
#      next if subteam == team
#
#      team[:member] << subteam[:dn]
#    end
#  end
#end

comp = """version: 1

dn: dc=marvel-corp,dc=com
cn: marvel-corp
objectClass: dcObject
objectClass: organization
dc: marvel-corp
o: Marvel Corp.

# USERS TREE

dn: ou=users,dc=marvel-corp,dc=com
objectClass: organizationalUnit

# GROUPS TREE

dn: ou=groups,dc=marvel-corp,dc=com
objectClass: organizationalUnit

# ADMIN USER

dn: uid=admin,ou=users,dc=marvel-corp,dc=com
cn: Admin
sn: administrator
displayName: Directory Superuser
uid: admin
userPassword: secret
mail: admin@marvel-corp.com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson

# ADMIN GROUP

dn: cn=superheroes,ou=groups,dc=marvel-corp,dc=com
cn: superheroes
objectClass: groupOfNames
member: uid=magneto,ou=users,dc=marvel-corp,dc=com
member: uid=wolverine,ou=users,dc=marvel-corp,dc=com

"""

File.open('marvel-corp.ldif', 'w') do |ldif|
  ldif.puts comp

  ldif.puts
  ldif.puts "# GROUPS"
  ldif.puts
  add(teams, ldif)

  ldif.puts
  ldif.puts "# USERS"
  ldif.puts
  add(users, ldif)
end
