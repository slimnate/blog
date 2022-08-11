require 'liquid'
require 'uri'
require 'open-uri'
require 'rouge'

module Jekyll
    class RenderGithubTag < Liquid::Tag
        GITHUB_HOST_RAW  = 'raw.githubusercontent.com'

        def initialize(tag_name, text, tokens)
            super
            @text = text
        end

        def render(context)
            uri = URI(@text.strip)
            uri.host = GITHUB_HOST_RAW
            uri.path = uri.path.sub('/blob', '')
            code_lines = uri.open.readlines

            "```cpp\r\n#{code_lines.join}\r\n```"
        end
    end
end

Liquid::Template.register_tag('git_include', Jekyll::RenderGithubTag)