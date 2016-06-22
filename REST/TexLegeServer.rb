# TexLege.rb
require 'rubygems'
require 'pp'
require 'json'
require 'sinatra'
require 'securerandom'

### if you ever need to handle puts/posts
## gem install rack_csrf
##    then
## require "rack/csrf"

use Rack::Session::Cookie, :key => 'JSESSION_ID',
                           :expire_after => 60*60*24,
                           :secret => 'McKaHLjnqEJDmGjcM27HHfpb7'
## use Rack::Csrf, :raise => true
### Then in the client's PUT/POST, return that csrf tag

use Rack::CommonLogger 

set :logging,true
set :bind, '0.0.0.0'

## ------------------------------------------------------------------------------------------------------------------------
## -- CONSTANTS
## ------------------------------------------------------------------------------------------------------------------------

AUTH_USER_NAME = "texlegeRead"
AUTH_USER_PWD  = "uiNrWFJmdMto6H6a7"
BUNDLE_SUFFIX  = "JSONBundle"

## ------------------------------------------------------------------------------------------------------------------------
## -- HELPER METHODS
## ------------------------------------------------------------------------------------------------------------------------

## ------------------------------------------------------------------------------------------------------------------------
## helper for writing pretty-print JSON
class File  
  ## Pretty-print String -> object 
  def pp(*objs)
    objs.each {|obj|
      PP.pp(obj, self)
    }
    objs.size <= 1 ? objs.first : objs
  end

  ## Pretty-print String -> JSON 
  def jj(*objs)
    objs.each {|obj|
      obj = JSON.parse(obj.to_json)
      self.puts JSON.pretty_generate(obj)
    }
    objs.size <= 1 ? objs.first : objs
  end
end

## ------------------------------------------------------------------------------------------------------------------------
def load_and_parse_json json_file
  parsed = JSON.load json_file
  parsed
rescue JSON::ParserError => e
  puts "We can't parse malformed JSON! (#{e.message})"
  exit 2
end

## ------------------------------------------------------------------------------------------------------------------------
def template( templateStr, values )
  templateStr.gsub( /:::(.*?):::/ ) { values[ $1 ].to_str }
end

## ------------------------------------------------------------------------------------------------------------------------
## -- MAIN SINATRA STUFF
## ------------------------------------------------------------------------------------------------------------------------
use Rack::Auth::Basic, "Restricted Area" do |username, password|
  [username, password] == [AUTH_USER_NAME, AUTH_USER_PWD]
end

configure do
  mime_type 'application/json'
### Does this work to support CORS?
###  access_control_allow_origin '*'
end

# -------------------------------------------------------------------
before do
  session[:id] ||= SecureRandom.random_number
  #cache_control  :static_cache_control, :public, :must_revalidate, :max_age => 60
  #some debug info
  user_agent = env.fetch('HTTP_USER_AGENT','')
  # p "BEFORE DO accept:[#{request.accept}] method[#{request.request_method}] "\
  #   "path[#{request.path_info}] content-lenght[#{request.content_length}] "\
  #   "media-type[#{request.media_type}] if-none[#{env['HTTP_IF_NONE_MATCH']}] "\
  #   "session[#{session[:id]}] user_agent [#{user_agent}]"
  p "BEFORE DO method[#{request.request_method}] path[#{request.path_info}] if-none[#{env['HTTP_IF_NONE_MATCH']}] "\
    "session[#{session[:id]}]"
end


# -------------------------------------------------------------------
# batching
post '/:cloud/v1/batch' do
  p 'BATCH REQUEST!!!!"'
  pp params
  
  request.body.rewind
  request_payload = JSON.parse request.body.read
  pp request_payload

  request_payload["requests"].each { |request| 
    req_method = request["method"]
    next if req_method != 'GET'   #only GET for now
    
    req_id = request["id"]
  }

  "thanks!"
end


# -------------------------------------------------------------------
# paginated list - so we can simulate pagination
#
# get '/:cloud/v1/paginatedThings' do
#   if_none_match = env['HTTP_IF_NONE_MATCH']
#   index = if_none_match && if_none_match.length > 0 ? if_none_match.tr('"','') : "0"
#   p "    START =============================== GETTING MORE /paginatedThings #{index} ========================================="
#   # index = "99" if index == "100"
#   index = "99" if index == "100"
#   file_to_serve = "texlege.JSONBundle/paginatedThings/index.json.#{index}"
#   p "if_none_match #{if_none_match} - index #{index} - file_to_serve #{file_to_serve}"

#   if File.exists?(file_to_serve)
#     # calculate the HASH for index.json
#     next_index = (index.to_i + 1).to_s
#     content_type "application/json"
#     etag "#{next_index}"
#     # response['Expires'] = (Time.now + 60*2).httpdate
#     sleep(0.2)
#     send_file file_to_serve
#   else
#     halt 404, "#{file_to_serve} -- #{request.accept} Not Found!"
#   end
#   p "    END =============================== GETTING MORE /paginatedThings #{index} ==========================================="
# end

# -------------------------------------------------------------------
# /metadata -- let's return the correct resource-index based on user-agent
#
get '/:cloud/v1/metadata' do

  user_agent = env.fetch('HTTP_USER_AGENT','').downcase
  p "HELLLLOOOOO THERE USERAGENT == [#{user_agent}]"
  
  # DEFAULT to HCM-index
  file_to_serve = "#{params[:cloud]}.#{BUNDLE_SUFFIX}/metadata/index.json"
  # file_to_serve = "#{params[:cloud]}.#{BUNDLE_SUFFIX}/metadata/phone-index.json" if user_agent["iphone"]
  # file_to_serve = "#{params[:cloud]}.#{BUNDLE_SUFFIX}/metadata/tablet-index.json" if user_agent["ipad"]
  
  if File.exists?(file_to_serve)
    # p "========= METADATA for #{user_agent} -- #{file_to_serve} -- cloud #{params[:cloud]} ================"
    etag "#{file_to_serve}-#{File.size(file_to_serve)}-#{File.mtime(file_to_serve)}".hash
    send_file file_to_serve
  else
    file_to_serve = "#{params[:cloud]}.#{BUNDLE_SUFFIX}/metadata/index.json"
    if File.exists?(file_to_serve)
      # sleep(20) // debug only
      send_file file_to_serve
    else
      halt 404, "#{file_to_serve} -- #{request.accept} Not Found!"
    end
  end  
end


# -------------------------------------------------------------------
# main route
#
get '/:cloud/v1/*' do

  #sleep(1*60)

  final_stuff = params[:splat]
  final_stuff = params[:splat]
  # p "FINAL STUFF #{final_stuff}"
  final_stuff = final_stuff[0].tr('"', '')
  # p "FINAL STUFF #{final_stuff}"
  file_prefix = "#{params[:cloud]}.#{BUNDLE_SUFFIX}/#{final_stuff}"

  #handle different files
  file_to_serve = ""
  file_to_serve = file_prefix if File.exists?(file_prefix)
  file_to_serve = "#{file_prefix}/index.json" if File.exists?("#{file_prefix}/index.json")
  # p "WASUP - [#{file_prefix}] - filetoserver [#{file_to_serve}]"

  if File.exists?(file_to_serve)
    # p "serving file #{file_to_serve}"
    etag "#{file_to_serve}-#{File.size(file_to_serve)}-#{File.mtime(file_to_serve)}".hash
    # response['content_length'] = File.size(file_to_serve)
    # cache_control :no_cache, :no_store, :must_revalidate if final_stuff == "userInfo"
    send_file file_to_serve
  else
    halt 404, "#{file_to_serve} -- #{request.accept} Not Found!"
  end
end
