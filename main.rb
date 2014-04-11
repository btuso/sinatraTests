require 'bundler'
Bundler.require

get '/' do
	"Halo"
end

post '/channel/:channel_name/post' do |channel_name|
    channel = settings.channels.getOrCreateChannel(channel_name)
    json_post = JSON.parse(request.body.read)
    post = create_post_from_json(channel.get_top, json_post)
    channel.make_post(post)
    post.content
end

def create_post_from_json(id, json_post)
    content = json_post["content"]
    media = json_post["media"]
    #this method to set an id is useless right now, but whatever
    return Post.new(id, content, media)
end

get '/channel/:channel_name/:post_id' do |channel_name, post_id|
    channel = settings.channels.getOrCreateChannel(channel_name)
	post = channel.get_post(post_id)
    if post != nil 
        post.content
    else
        "post not found"
    end
end

module Content_chain
    attr_reader :content_id

    def initialize(id)
        @content_id = id
        @post_chain = Post_chain.new
    end

    def make_post(post)
        @post_chain.putContent(post)
    end

    def get_post(post_id)
       return @post_chain.getContent(post_id)
    end

    def get_top
        return @post_chain.get_top
    end
end

class Post_chain
    def initialize 
        @chain = []
    end

    def getContent(id)
        return @chain.at(id.to_i)
    end

    def putContent(post)
        @chain << post
    end

    def get_top
        return @chain.length
    end
end

class Channel 
    include Content_chain
end

class Post 
    include Content_chain
    attr_reader :content    
    attr_reader :media

    def initialize(id, content, media)
        super(id)
        @content = content
        @media = media
    end
end

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

