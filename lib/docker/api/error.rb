module Docker
    module API

      ##
      # This class represents a validation error.
      class ValidationError < StandardError

        ##
        # @params permitted [Array]: permitted values.
        # @params unpermitted [Array]: unpermitted values.
        def initialize permitted, unpermitted
          super("Unpermitted options found: #{unpermitted.to_s}. Permitted are #{permitted.to_s}")
        end
      end

      ##
      # This class represents a parameter validation error.
      class InvalidParameter < Docker::API::ValidationError; end

      ##
      # This class represents a request body validation error.
      class InvalidRequestBody < Docker::API::ValidationError; end

      ##
      # This class represents a generic error.
      class Error < StandardError
        def initialize msg = "Error without specific message"
          super(msg)
        end
      end
      
    end
  end