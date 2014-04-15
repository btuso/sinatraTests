require 'bundler'
Bundler.require
require_relative 'content_objects/Channel'
require_relative 'content_objects/Post'

get '/' do
	"Halo"
end

#%r{/channel/([a-zA-Z0-9]+)/((?:[0-9]*/)*)([0-9]+$|[a-zA-Z]+$)}
# /channel/a-Z0-9/##/##||aa

get %r{/channel/([a-zA-Z0-9]+)/((?:[0-9]*/)*)([0-9]+$)} do
    channel_name = params[:captures].first
    channel = settings.channels.getOrCreateChannel(channel_name)
    requested_post_id = params[:captures].last
    sub_posts_ids = request.path_info.scan(/([0-9]+)\//).flatten
      
    if !channel.has_posts 
        halt(404, "Content owner not found")
    end
    content_owner = find_content_owner(channel, sub_posts_ids)
    post = content_owner.get_post(requested_post_id)
    if post != nil 
        post.inspect
    else
        "post not found"
    end
end

def find_content_owner(channel, post_ids)
    if post_ids.length == 0
        return channel
    end

    initial_post_id = post_ids.shift
    post ||= channel.get_post(initial_post_id.to_i) || halt(404, "initial post is null")

    post_ids.each{ |post_id|
        post = post.get_post(post_id) || halt(404, "post is null")
    }

    return post
end

post %r{/channel/([a-zA-Z0-9]+)/((?:[0-9]*/)*)([a-zA-Z]+$)} do
    channel_name = params[:captures].first
    channel = settings.channels.getOrCreateChannel(channel_name)
    sub_posts_ids = request.path_info.scan(/([0-9]+)\//).flatten
    content_owner = find_content_owner(channel, sub_posts_ids) 

    json_post = JSON.parse(request.body.read)
    post = create_post_from_json(channel.get_top, json_post)
    content_owner.make_post(post)
    post.content
end

def create_post_from_json(id, json_post)
    content = json_post["content"]
    media = json_post["media"]
    #this method to set an id is useless right now, but whatever
    return Post.new(id, content, media)
end


###########################################

#figure out what to do with this class
class Channels

    def initialize
        @channels = []
    end

    def getOrCreateChannel(channel_id)
        @channels.each{|channel|
            if channel.content_id==channel_id
                return channel
            end
        }      
        
        new_channel = Channel.new(channel_id)
        @channels << new_channel
        return new_channel
    end

    def getChannels
        return @channels.length
    end
end
set :channels, Channels.new
# /channel/cars/post?
# 			creates a post with id:0 in cars
# /channel/cars/:id
# 				the post
# /channel/cars/:id/post?
# 				creates a sub post, 0/0
# /channel/cars/:id/:id
# 				the post 0/0
# /channel/cars/:id/post?
# 				creates a sub post 0/1

