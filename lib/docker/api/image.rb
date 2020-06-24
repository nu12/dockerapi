module Docker
    module API
        class Image < Docker::API::Base
            require "base64"

            def self.base_path
                "/images"
            end

            [{name: "inspect", path: "json"},
             {name: "history", path: "history"}].each do | method |
                define_singleton_method(method[:name]) { | name | connection.get(build_path([name, method[:path]])) }
            end

            def self.list params = {}
                validate Docker::API::InvalidParameter, [:all, :filters, :digests], params
                connection.get(build_path(["json"], params))
            end

            def self.remove name, params = {}
                validate Docker::API::InvalidParameter, [:force, :noprune], params
                connection.delete(build_path([name], params))
            end

            def self.tag name, params = {}
                validate Docker::API::InvalidParameter, [:repo, :tag], params
                connection.post(build_path([name, "tag"], params))
            end

            def self.prune params = {}
                validate Docker::API::InvalidParameter, [:filters], params
                connection.post(build_path(["prune"], params))
            end

            def self.create params = {}, authentication = {}
                validate Docker::API::InvalidParameter, [:fromImage, :fromSrc, :repo, :tag, :message, :platform], params
                
                if authentication.keys.size > 0
                    auth = Docker::API::System.auth(authentication)
                    return auth unless [200, 204].include? auth.status
                    connection.request(method: :post, path: build_path(["create"], params), headers: { "X-Registry-Auth" => Base64.encode64(authentication.to_json.to_s).chomp } )
                elsif params.has_key? :fromSrc
                    if params[:fromSrc].match(/^(http|https)/)
                        connection.request(method: :post, path: build_path(["create"], params))
                    else
                        file = File.open(File.expand_path(params[:fromSrc]), "r")
                        params[:fromSrc] = "-"
                        response = connection.request(method: :post, path: build_path(["create"], params) , headers: {"Content-Type" => "application/x-tar"}, request_block: lambda { file.read(Excon.defaults[:chunk_size]).to_s} )
                        file.close
                        response
                    end
                else
                    connection.post(build_path(["create"], params))
                end
            end

        end

    end
end