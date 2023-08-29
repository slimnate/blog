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

        def infer_lang(url)
            extension = url.rpartition('.').last
            if(extension == 'cpp' || extension == 'h')
                return 'cpp'
            else
                return extension
            end
        end

        def render(context)
            # Get params from invocation
            params = @text.strip.split
            # first param is url
            uri = URI(params[0])
            # second param is lang
            lang = params[1]
            # if no lang provided, try to detect from url from url
            if lang.nil?
                lang = infer_lang(params[0])
            end

            uri.host = GITHUB_HOST_RAW
            uri.path = uri.path.sub('/blob', '')
            code_lines = uri.open.readlines

            "```#{lang}\r\n#{code_lines.join}\r\n```"
        end
    end
end

Liquid::Template.register_tag('git_include', Jekyll::RenderGithubTag)