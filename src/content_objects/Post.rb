require_relative 'chains/Content_chain'
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
