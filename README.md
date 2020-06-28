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

### Images

```ruby
# Pull from a public repository
Docker::API::Image.create( fromImage: "nginx:latest" )

# Pull from a private repository
Docker::API::Image.create( {fromImage: "private/repo:tag"}, {username: "janedoe", password: "password"} )

# Create image from local tar file
Docker::API::Image.create( fromSrc: "/path/to/file.tar", repo: "repo:tag" )

# Create image from remote tar file
Docker::API::Image.create( fromSrc: "https://url.to/file.tar", repo: "repo:tag" )

# List images
Docker::API::Image.list
Docker::API::Image.list( all:true )

# Inspect image
Docker::API::Image.inspect("image")

# History
Docker::API::Image.history("image")

# Search image
Docker::API::Image.search(term: "busybox", limit: 2)
Docker::API::Image.search(term: "busybox", filters: {"is-automated": {"true": true}})
Docker::API::Image.search(term: "busybox", filters: {"is-official": {"true": true}})

# Tag image
Docker::API::Image.tag("current:tag", repo: "new:tag") # or
Docker::API::Image.tag("current:tag", repo: "new", tag: "tag")

# Push image
Docker::API::Image.push("repo:tag") # to dockerhub
Docker::API::Image.push("localhost:5000/repo:tag") # to local registry
Docker::API::Image.push("private/repo", {tag: "tag"}, {username: "janedoe", password: "password"} # to private repository

# Remove container
Docker::API::Image.remove("image")
Docker::API::Image.remove("image", force: true)

# Remove unsued images (prune)
Docker::API::Image.prune(filters: {dangling: {"false": true}})

# Create image from a container (commit)
Docker::API::Image.commit(container: container, repo: "my/image", tag: "latest", comment: "Comment from commit", author: "dockerapi", pause: false )

# Build image from a local tar file
Docker::API::Image.build("/path/to/file.tar")

# Build image from a remote tar file
Docker::API::Image.build(nil, remote: "https://url.to/file.tar")

# Build image from a remote Dockerfile
Docker::API::Image.build(nil, remote: "https://url.to/Dockerfile")

# Delete builder cache
Docker::API::Image.delete_cache

# Export repo
Docker::API::Image.export("repo:tag", "~/exported_image.tar")

# Import repo
Docker::API::Image.import("/path/to/file.tar")
```

### Containers 

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

### Volumes

```ruby
# Create volume
Docker::API::Volume.create( Name:"my-volume" )

# List volumes
Docker::API::Volume.list

# Inspect volume
Docker::API::Volume.inspect("my-volume")

# Remove volume
Docker::API::Volume.remove("my-volume")

# Remove unused volumes (prune)
Docker::API::Volume.prune
```

### Network

```ruby
# List networks
Docker::API::Network.list

# Inspect network
Docker::API::Network.inspect("bridge")

# Create network
Docker::API::Network.create( Name:"my-network" )

# Remove network
Docker::API::Network.remove("my-network")

# Remove unused network (prune)
Docker::API::Network.prune

# Connect container to a network
Docker::API::Network.connect( "my-network", Container: "my-container" )

# Disconnect container to a network
Docker::API::Network.disconnect( "my-network", Container: "my-container" )
```

### Requests

Requests should work as described in [Docker API documentation](https://docs.docker.com/engine/api/v1.40). Check it out to customize your requests.

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
| Image | Ok | Ok | NS |
| Volume | Ok | Ok | NS |
| Network | Ok | Ok | NS |
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

