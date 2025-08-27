require "excon"
require "json"
require "base64"
require "fileutils"

require "docker/api/version"
require "docker/api/connection"
require "docker/api/response"
require "docker/api/base"
require "docker/api/container"
require "docker/api/image"
require "docker/api/volume"
require "docker/api/network"
require "docker/api/exec"
require "docker/api/system"
require "docker/api/swarm"
require "docker/api/node"
require "docker/api/service"
require "docker/api/task"
require "docker/api/secret"
require "docker/api/config"
require "docker/api/plugin"

module Docker
  module API

    ##
    # This variable controls output verbosity.
    def self.print_to_stdout
      @@print_to_stdout
    end
    def self.print_to_stdout=(bool)
      @@print_to_stdout = bool
    end
    self.print_to_stdout = true

    ##
    # This variable controls output verbosity.
    def self.print_response_to_stdout
      @@print_response_to_stdout
    end
    def self.print_response_to_stdout=(bool)
      @@print_response_to_stdout = bool
    end
    self.print_response_to_stdout = false

    ##
    # This variable controls the default Docker API version.
    def self.default_api_version
      @@default_api_version
    end
    def self.default_api_version=(s)
      @@default_api_version = s
    end
    self.default_api_version = "1.43"
    
  end
end
