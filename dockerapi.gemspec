require_relative 'lib/docker/api/version'

Gem::Specification.new do |spec|
  spec.name          = "dockerapi"
  spec.version       = Docker::API::GEM_VERSION
  spec.authors       = ["Alysson A. Costa"]
  spec.email         = ["alysson.avila.costa@gmail.com"]

  spec.summary       = "Interact with Docker API from Ruby code."
  spec.description   = "Interact with Docker API directly from Ruby code. Comprehensive implementation (all available endpoints), no local Docker installation required, easily manipulated http responses."
  spec.homepage      = "https://github.com/nu12/dockerapi"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nu12/dockerapi.git"
  spec.metadata["changelog_uri"] = "https://github.com/nu12/dockerapi/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/dockerapi"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|resources)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("excon", "~> 0.76")
end
