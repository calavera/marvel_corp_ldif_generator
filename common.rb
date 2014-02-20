require 'digest/md5'
require 'json'
require 'net/http'
require 'securerandom'
require 'uri'

STDOUT.sync = true

PUBLIC_KEY  = '142c2c28a28d7c61a5dc05ddd69db733'
PRIVATE_KEY = 'a40a2ca13e3b1db6d2856dcd05877a551e7efcbd'

pages = []
offset = 0

def query(path, offset)
  ts = SecureRandom.hex(4)
  hash = Digest::MD5.hexdigest(ts + PRIVATE_KEY + PUBLIC_KEY)

  "http://gateway.marvel.com/v1/public/#{path}?ts=#{ts}&apikey=#{PUBLIC_KEY}&hash=#{hash}&limit=100&offset=#{offset}"
end

def get(path, offset)
  resp = Net::HTTP.get_response(URI(query(path, offset)))
  unless resp.is_a?(Net::HTTPOK)
    p resp
    exit(1)
  end
  resp
end

def slug(name)
  name.strip.downcase.gsub(/[^\p{Word}]+/, '-').chomp('-')
end

def norm_name(name)
  name.split(" by ").first.split(/\/|:|#|,/).first.gsub(%r{(.+)\(.+\)}, '\1').gsub(/[^\p{Word}]+/, ' ').strip
end

def add(collection, file)
  collection.each do |member|
    member.each do |key, value|
      if value.respond_to?(:each)
        value.each do |v|
          file.puts "#{key}: #{v}"
        end
      else
        file.puts "#{key}: #{value}"
      end
    end
    file.puts
  end
end
