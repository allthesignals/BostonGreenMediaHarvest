require 'flickraw'
require 'csv'
require 'pg'
require 'Sequel'
require 'Geometry'

FlickRaw.api_key="ea626fdb3a9e9f4c5dbe0a742b278190"
FlickRaw.shared_secret="dfaa1cd16b2c85ed"
conn=PGconn.connect( :host=>"localhost", :port=>5432, :dbname=>"harvest")
conn = Sequel.postgres(:host=>"localhost", :database=>"harvest", :username=>"Matt")

data = []
hash = Hash.new("undefined")

hash = {"code" => [], "title" => [], "description" => [], "examples" => [] }

# grid = conn.exec("SELECT * FROM parksgrid")
grid = conn[:parksgrid].all


def to_bbox(record)
  "#{record['x_min']},#{record['y_min']},#{record['x_max']},#{record['y_max']}"
end

def quote (str)
  str.gsub(/\\|'/) { |c| "\\#{c}" }
end

#     Table "public.flickr_response"
#      Column     |   Type   | Modifiers
# ----------------+----------+-----------
#  id             | integer  |
#  owner          | text     |
#  secret         | text     |
#  server         | text     |
#  farm           | text     |
#  title          | text     |
#  ispublic       | integ
#  isfriend       | integer  |
#  isfamily       | integer  |
#  license        | integer  |
#  dateupload     | integer  |
#  ownername      | text     |
#  location       | geometry |
#  accuracy       | integer  |
#  context        | integer  |
#  place_id       | text     |
#  woeid          | text     |
#  geo_is_family  | integer  |
#  geo_is_friend  | integer  |
#  geo_is_contact | integer  |
#  geo_is_public  | integer  |
#  url            | text     |
# id owner secret server farm title ispublic isfriend isfamily license dateupload ownername location accuracy context place_id woeid geo_is_family geo_is_friend geo_is_contact geo_is_public url

# CSV.foreach("parksBBox.csv", headers: true) do |r|
grid.each do |r|

  bbox = to_bbox(r)

  response = flickr.photos.search(:bbox=> bbox, :extras=>"license, geo, date_upload, owner_name")

  response.each do |r|
    r['id']

    url = FlickRaw.url_b(r)

    conn.exec("INSERT INTO flickr_response VALUES (#{r['id']}, '#{r['owner']}', '#{r['secret']}', '#{r['server']}', '#{r['farm']}', 'Photo', #{r['ispublic']}, #{r['isfriend']}, #{r['isfamily']}, #{r['license']}, #{r['dateupload']}, '#{conn.escape_string(r['ownername'])}', ST_GeomFromText('POINT(#{r['longitude']} #{r['latitude']})', 4326), 0, 0, '', '', 0, 0, 0, 0, '#{url}')")
    puts r['title']

  end
end