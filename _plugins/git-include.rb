require 'liquid'
require 'uri'
require 'open-uri'
require 'rouge'

module Jekyll

    class RenderGithubTag < Liquid::Tag
        GITHUB_HOST_RAW  = 'raw.githubusercontent.com'

        VALID_EXTS = ['abap','actionscript','ada','apache','apex','apiblueprint','applescript','armasm','augeas','awk','batchfile','bbcbasic','bibtex','biml','bpf','brainfuck','brightscript','bsl','c','ceylon','cfscript','cisco_ios','clean','clojure','cmake','cmhg','coffeescript','common_lisp','conf','console','coq','cpp','crystal','csharp','css','csvs','cuda','cypher','cython','d','dafny','dart','datastudio','diff','digdag','docker','dot','ecl','eex','eiffel','elixir','elm','email','epp','erb','erlang','escape','factor','fluent','fortran','freefem','fsharp','gdscript','ghc-cmm','ghc-core','gherkin','glsl','go','gradle','graphql','groovy','hack','haml','handlebars','haskell','haxe','hcl','hlsl','hocon','hql','html','http','hylang','idlang','idris','igorpro','ini','io','irb','irb_output','isabelle','isbl','j','janet','java','javascript','jinja','jsl','json','json-doc','jsonnet','jsp','jsx','julia','kotlin','lasso','lean','liquid','literate_coffeescript','literate_haskell','livescript','llvm','lua','lustre','lutin','m68k','magik','make','markdown','mason','mathematica','matlab','meson','minizinc','moonscript','mosel','msgtrans','mxml','nasm','nesasm','nginx','nial','nim','nix','objective_c','objective_cpp','ocaml','ocl','openedge','opentype_feature_file','pascal','perl','php','plaintext','plist','plsql','pony','postscript','powershell','praat','prolog','prometheus','properties','protobuf','puppet','python','q','qml','r','racket','reasonml','rego','rescript','rml','robot_framework','ruby','rust','sas','sass','scala','scheme','scss','sed','shell','sieve','slice','slim','smalltalk','smarty','sml','sparql','sqf','sql','ssh','stan','stata','supercollider','swift','systemd','syzlang','syzprog','tap','tcl','terraform','tex','toml','tsx','ttcn3','tulip','turtle','twig','typescript','vala','vb','vcl','velocity','verilog','vhdl','viml','vue','wollok','xml','xojo','xpath','xquery','yaml','yang','zig'];

        def initialize(tag_name, text, tokens)
            super
            @text = text
        end

        def infer_lang(url)
            extension = url.rpartition('.').last
            if(extension == 'cpp' || extension == 'h' || extension == 'ino')
                return 'cpp'
            elsif VALID_EXTS.include? extension
                return extension
            else
                return ''
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