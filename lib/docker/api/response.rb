module Docker
    module API
        class Response < Excon::Response
            attr_reader(:json, :path)

            def initialize data
                super data
                @json = parse_json @body
                @path = @data[:path]
            end

            def success?
                (200..204).include? @status
            end

            private

            def parse_json data
               return nil unless headers["Content-Type"] == "application/json"
               return nil if data == ""
               data.split("\r\n").size > 1 ? data.split("\r\n").map{ |e| eval(e) } : JSON.parse(data)
            end
        end
    end
end