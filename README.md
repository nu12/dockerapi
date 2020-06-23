# dockerapi

Interact directly with Docker API from Ruby code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dockerapi'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dockerapi

## Usage

Let's test a Nginx container

```ruby
# Pull nginx image
Docker::API::Image.create( fromImage: "nginx:latest" )

# Create container
Docker::API::Container.create( {name: "nginx"}, {Image: "nginx:latest", HostConfig: {PortBindings: {"80/tcp": [ {HostIp: "0.0.0.0", HostPort: "80"} ]}}})

# Start container
Docker::API::Container.start("nginx")

# Open localhost or machine IP to check the container running

# Restart container
Docker::API::Container.restart("nginx")

# Pause/unpause container
Docker::API::Container.pause("nginx")
Docker::API::Container.unpause("nginx")

# List containers
Docker::API::Container::list

# List containers (including stopped ones)
Docker::API::Container::list(all: true)

# Inspect container
Docker::API::Container.inspect("nginx")

# View container's processes
Docker::API::Container.top("nginx")

# Let's enhance the output
JSON.parse(Docker::API::Container.top("nginx").body)

# View filesystem changes
Docker::API::Container.changes("nginx")

# View filesystem logs
Docker::API::Container.logs("nginx", stdout: true)
Docker::API::Container.logs("nginx", stdout: true, follow: true)

# View filesystem stats
Docker::API::Container.stats("nginx", stream: true)

# Export container
Docker::API::Container.export("nginx", "~/exported_container")

# Get files from container
Docker::API::Container.archive("nginx", "~/html.tar", path: "/usr/share/nginx/html/")

# Stop container
Docker::API::Container.stop("nginx")

# Remove container
Docker::API::Container.remove("nginx")

# Remove stopped containers (prune)
Docker::API::Container.prune
```

### Requests

Requests should work as described in Docker API documentation.

### Response

All requests return a Excon::Response object.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Road to 1.0.0

NS: Not Started

WIP: Work In Progress


| Class | Tests | Implementation | Refactoring |
|---|---|---|---|
| Container | Ok | Ok | NS |
| Image | WIP | WIP | NS |
| Volume | NS | NS | NS |
| Network | NS | NS | NS |
| System | NS | NS | NS |
| Exec | NS | NS | NS |
| Swarm | NS | NS | NS |
| Node | NS | NS | NS |
| Service | NS | NS | NS |
| Task | NS | NS | NS |
| Secret | NS | NS | NS |

Misc: 
* Improve response object
* Improve error objects

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nu12/dockerapi.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

