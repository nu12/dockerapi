module Docker
    module API
      class ValidationError < StandardError
        def initialize permitted, unpermitted
          super("Unpermitted options found: #{unpermitted.to_s}. Permitted are #{permitted.to_s}")
        end
      end
      class Error < StandardError
        def initialize msg = "Error without specific message"
          super(msg)
        end
      end

      class InvalidParameter < Docker::API::ValidationError; end
      class InvalidRequestBody < Docker::API::ValidationError; end
    end
  end