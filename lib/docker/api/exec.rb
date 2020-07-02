module Docker
    module API
        class Exec < Docker::API::Base

            def self.base_path
                "/exec"
            end

            def self.create name, body = {}
                validate Docker::API::InvalidRequestBody, [:AttachStdin, :AttachStdout, :AttachStderr, :DetachKeys, :Tty, :Env, :Cmd, :Privileged, :User, :WorkingDir], body
                connection.request(method: :post, path: "/containers/#{name}/exec", headers: {"Content-Type": "application/json"}, body: body.to_json )
            end

            def self.start name, body = {}
                validate Docker::API::InvalidRequestBody, [:Detach, :Tty], body

                stream = ""
                response = connection.request(method: :post, 
                    path: "/exec/#{name}/start", 
                    headers: {"Content-Type": "application/json"},  
                    body: body.to_json, 
                    response_block: lambda { |chunk, remaining_bytes, total_bytes| stream += chunk.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?') }
                )
                response.data.merge!({stream: stream})
                response
            end

            def self.resize name, params = {}
                validate Docker::API::InvalidParameter, [:w, :h], params
                connection.post(build_path([name, "resize"], params))
            end

            def self.inspect name
                connection.get(build_path([name, "json"]))
            end

        end
    end
end