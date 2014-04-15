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

    def has_posts
        return @post_chain.get_top > 0
    end
end

#delete this class
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
