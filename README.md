# dockerapi

Interact with Docker API directly from Ruby code. Comprehensive implementation (all available endpoints), no local Docker installation required, easily manipulated http responses.

* [Installation](#installation)
* [Usage](#usage)
  * [Images](#images)
  * [Containers](#containers)
  * [Volumes](#volumes)
  * [Network](#network)
  * [System](#system)
  * [Exec](#exec)
  * [Swarm](#swarm)
  * [Node](#node)
  * [Service](#service)
  * [Task](#task)
  * [Secret](#secret)
  * [Config](#config)
  * [Plugin](#plugin)
  * [Connection](#connection)
  * [Requests](#requests)
  * [Response](#response)
  * [Error handling](#error-handling)
  * [Blocks](#blocks)
* [Development](#development)
* [Contributing](#contributing)
* [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dockerapi'
# or
gem 'dockerapi', github: 'nu12/dockerapi'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dockerapi

## Usage

The following section will bring you up to speed in order to use most this gem resources with pratical examples. 

If you need more information about the different Docker API endpoints, please see the [Docker API documentation](https://docs.docker.com/engine/api/v1.40/). 

For a more detailed and comprehensive documentation about this gem's API, please see the [documentation page](https://rubydoc.info/gems/dockerapi).

### Images

```ruby
# Connect to local image endpoints
image = Docker::API::Image.new

# Pull from a public repository
image.create( fromImage: "nginx:latest" )

# Pull from a private repository
image.create( {fromImage: "private/repo:tag"}, {username: "janedoe", password: "password"} )

# Create image from local tar file
image.create( fromSrc: "/path/to/file.tar", repo: "repo:tag" )

# Create image from remote tar file
image.create( fromSrc: "https://url.to/file.tar", repo: "repo:tag" )

# List images
image.list

# Inspect image
image.details("image")

# Return image digest and platform information by contacting the registry.
image.distribution("image")
image.distribution("image", {username: "janedoe", password: "password"}) # private repository

# History
image.history("image")

# Search image
image.search(term: "busybox", limit: 2)
image.search(term: "busybox", filters: {"is-automated": {"true": true}})
image.search(term: "busybox", filters: {"is-official": {"true": true}})

# Tag image
image.tag("current:tag", repo: "new:tag") # or
image.tag("current:tag", repo: "new", tag: "tag")

# Push image
image.push("repo:tag") # to dockerhub
image.push("localhost:5000/repo:tag") # to local registry
image.push("private/repo", {tag: "tag"}, {username: "janedoe", password: "password"}) # to private repository

# Remove image
image.remove("image")
image.remove("image", force: true)

# Remove unsued images (prune)
image.prune(filters: {dangling: {"false": true}})

# Create image from a container (commit)
image.commit(container: container, repo: "my/image", tag: "latest", comment: "Comment from commit", author: "dockerapi", pause: false )

# Build image from a local tar file
image.build("/path/to/file.tar", {t: "tag"})

# Build image using private repository
image.build("/path/to/file.tar", {t: "tag"}, {"https://index.docker.io/v1/" => {username: "janedoe", password: "janedoe"}})

# Build image from a remote tar file
image.build(nil, {remote: "https://url.to/file.tar", t: "tag"})

# Build image from a remote Dockerfile
image.build(nil, {remote: "https://url.to/Dockerfile", t: "tag"})

# Delete builder cache
image.delete_cache

# Export repo
image.export("repo:tag", "~/exported_image.tar")

# Import repo
image.import("/path/to/file.tar")
```

### Containers 

Let's test a Nginx container

```ruby
# Pull nginx image
Docker::API::Image.new.create( fromImage: "nginx:latest" )

# Connect to local container endpoints
container = Docker::API::Container.new

# Create container
container.create( {name: "nginx"}, {Image: "nginx:latest", HostConfig: {PortBindings: {"80/tcp": [ {HostIp: "0.0.0.0", HostPort: "80"} ]}}})

# A more complex container creation
container.create(                    
    {name: "nginx"}, 
    {
        Image: "nginx:latest", 
        HostConfig: {
            PortBindings: {
                "80/tcp": [ {HostIp: "0.0.0.0", HostPort: "80"} ]
            }
        },
        Env: ["DOCKER=nice", "DOCKERAPI=awesome"],
        Cmd: ["echo", "hello from test"],
        Entrypoint: ["sh"],
        NetworkingConfig: { 
            EndpointsConfig: {
                EndpointSettings: {
                    IPAddress: "192.172.0.100"
                }
            }
        }
    }
)

# Start container
container.start("nginx")

# Open localhost or machine IP to check the container running

# Restart container
container.restart("nginx")

# Pause/unpause container
container.pause("nginx")
container.unpause("nginx")

# List containers
container.list

# List containers (including stopped ones)
container.list(all: true)

# Inspect container
container.details("nginx")

# View container's processes
container.top("nginx")

# Using json output
container.top("nginx").json

# View filesystem changes
container.changes("nginx")

# View container logs
container.logs("nginx", stdout: true)
container.logs("nginx", stdout: true, follow: true)

# View filesystem stats
container.stats("nginx", stream: true)

# Export container
container.export("nginx", "~/exported_container")

# Get files from container
container.get_archive("nginx", "~/html.tar", path: "/usr/share/nginx/html/")

# Send files to container
container.put_archive("nginx", "~/html.tar", path: "/usr/share/nginx/html/")

# Stop container
container.stop("nginx")

# Remove container
container.remove("nginx")

# Remove stopped containers (prune)
container.prune
```

### Volumes

```ruby
# Connect to local volume endpoints
volume = Docker::API::Volume.new

# Create volume
volume.create( Name:"my-volume" )

# List volumes
volume.list

# Inspect volume
volume.details("my-volume")

# Remove volume
volume.remove("my-volume")

# Remove unused volumes (prune)
volume.prune
```

### Network

```ruby
# Connect to local network endpoints
network = Docker::API::Network.new

# List networks
network.list

# Inspect network
network.details("bridge")

# Create network
network.create( Name:"my-network" )

# Remove network
network.remove("my-network")

# Remove unused network (prune)
network.prune

# Connect container to a network
network.connect( "my-network", Container: "my-container" )

# Disconnect container to a network
network.disconnect( "my-network", Container: "my-container" )
```

### System

```ruby
# Connect to local system endpoints
sys = Docker::API::System.new

# Ping docker api
sys.ping

# Docker components versions
sys.version

# System info
sys.info

# System events (stream)
sys.events(until: Time.now.to_i)

# Data usage information
sys.df
```

### Exec

```ruby
# Connect to local exec endpoints
exe = Docker::API::Exec.new

# Create exec instance, get generated exec ID
response = exe.create(container, AttachStdout:true, Cmd: ["ls", "-l"])
id = response.json["Id"]

# Execute the command, stream from Stdout is stored in response data
response = exe.start(id)
print response.data[:stream]

# Inspect exec instance
exe.details(id)
```

### Swarm
```ruby
# Connect to local swarm endpoints
swarm = Docker::API::Swarm.new

# Init swarm
swarm.init({AdvertiseAddr: "local-ip-address:2377", ListenAddr: "0.0.0.0:4567"})

# Inspect swarm
swarm.details

# Update swarm
swarm.update(version, {rotateWorkerToken: true})
swarm.update(version, {rotateManagerToken: true})
swarm.update(version, {rotateManagerUnlockKey: true})
swarm.update(version, {EncryptionConfig: { AutoLockManagers: true }})

# Get unlock key
swarm.unlock_key

# Unlock swarm
swarm.unlock(UnlockKey: "key-value")

# Join an existing swarm
swarm.join(RemoteAddrs: ["remote-manager-address:2377"], JoinToken: "Join-Token-Here")

# Leave a swarm
swarm.leave(force: true)
```

### Node
```ruby
# Connect to local node endpoints
node = Docker::API::Node.new

# List nodes
node.list

# Inspect node
node.details("node-id")

# Update node (version, Role and Availability must be present)
node.update("node-id", {version: "version"}, {Role: "worker", Availability: "pause" })
node.update("node-id", {version: "version"}, {Role: "worker", Availability: "active" })
node.update("node-id", {version: "version"}, {Role: "manager", Availability: "active" })

# Delete node
node.delete("node-id")
```

### Service
```ruby
# Connect to local service endpoints
service = Docker::API::Service.new

# List services
service.list

# Create a service
service.create({Name: "nginx-service", 
    TaskTemplate: {ContainerSpec: { Image: "nginx:alpine" }},
    Mode: { Replicated: { Replicas: 2 } },
    EndpointSpec: { Ports: [ {Protocol: "tcp", PublishedPort: 80, TargetPort: 80} ] }
})

# Update a service (needs version and current Spec)
version = service.details( service ).json["Version"]["Index"]
spec = service.details(service).json["Spec"]
service.update("nginx-service", {version: version}, spec.merge!({ Mode: { Replicated: { Replicas: 1 } } }))

# View service logs
service.logs("nginx-service", stdout: true)

# Inspect service 
service.details("nginx-service")

# Delete service 
service.delete("nginx-service")
```

### Task
```ruby
# Connect to local task endpoints
task = Docker::API::Task.new

# List tasks
task.list

# View task logs
task.logs("task-id", stdout: true)

# Inspect service 
task.details("task-id")
```

### Secret
```ruby
# Connect to local secret endpoints
secret = Docker::API::Secret.new

# List secrets
secret.list

# Create a secret
secret.create({Name: "secret-name", Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="})

# Inspect secrets 
secret.details("secret-name")

# Update a secret (needs version and current Spec)
version = secret.details( "secret-name" ).json["Version"]["Index"]
spec = secret.details("secret-name").json["Spec"]
secret.update("secret-name", {version: version}, spec.merge!({ Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg==" }))

# Delete secret
secret.delete("secret-name")
```

### Config
```ruby
# Connect to local config endpoints
config = Docker::API::Config.new

# List configs
config.list

# Create a config
config.create({Name: "config-name", Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="})

# Inspect configs 
config.details("config-name")

# Update a configs (needs version and current Spec)
version = config.details( "config-name" ).json["Version"]["Index"]
spec = config.details("config-name").json["Spec"]
config.update("config-name", {version: version}, spec.merge!({ Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg==" }))

# Delete config
config.delete("config-name")
```

### Plugin
```ruby
# Connect to local plugin endpoints
plugin = Docker::API::Plugin.new

# List plugins
plugin.list

# List plugin's privileges
plugin.privileges(remote: "plugin-name")

# Install plugin (using defined privileges)
privileges = plugin.privileges(remote: "plugin-name")
plugin.install({remote: "plugin-name"}, privileges)

# Upgrade plugin (using defined privileges)
privileges = plugin.privileges(remote: "plugin-name2")
plugin.upgrade("plugin-name", {remote: "plugin-name2"}, privileges)

# Enable plugin
plugin.enable("plugin-name", timeout: 0)

# Disable plugin
plugin.disable("plugin-name")

# Configure plugin
plugin.configure("plugin-name", ["DEBUG=1"])

# Inspect plugin
plugin.details("plugin-name")

# Remove plugin
plugin.remove("plugin-name")

# Create plugin (tar file must contain rootfs folder and config.json file)
plugin.create("name", "/path/to/file.tar")

# Push plugin
plugin.push("name")
```

### Connection

By default `Docker::API::Connection` will connect to local Docker socket at `/var/run/docker.sock`. See examples below to use a different path or connect to a remote address.

```ruby
# Setting different connections
local = Docker::API::Connection.new('unix:///', socket: "/path/to/docker.sock")
remote = Docker::API::Connection.new("http://127.0.0.1:2375") # change the IP address accordingly

# Using default /var/run/docker.sock
image_default = Docker::API::Image.new
image_default.list

# Using custom socket path
image_custom = Docker::API::Image.new(local)
image_custom.list

# Using remote address
image_remote = Docker::API::Image.new(remote)
image_remote.list
```

### Requests

Requests should work as described in [Docker API documentation](https://docs.docker.com/engine/api/v1.40). Check it out to customize your requests.

### Response

All requests return a response class that inherits from Excon::Response. Available attribute readers and methods include: `status`, `data`, `body`, `headers`, `json`, `path`, `success?`.

```ruby
response = Docker::API::Image.new.create(fromImage: "busybox:latest")

response
=> #<Docker::API::Response:0x000055bb390b35c0 ... >

response.status
=> 200

response.data
=> {:body=>"...", :cookies=>[], :host=>nil, :headers=>{ ... }, :path=>"/images/create?fromImage=busybox:latest", :port=>nil, :status=>200, :status_line=>"HTTP/1.1 200 OK\r\n", :reason_phrase=>"OK"}

response.headers
=> {"Api-Version"=>"1.40", "Content-Type"=>"application/json", "Docker-Experimental"=>"false", "Ostype"=>"linux", "Server"=>"Docker/19.03.11 (linux)", "Date"=>"Mon, 29 Jun 2020 16:10:06 GMT"}

response.body
=> "{\"status\":\"Pulling from library/busybox\" ... "

response.json
=> [{:status=>"Pulling from library/busybox", :id=>"latest"}, {:status=>"Pulling fs layer", :progressDetail=>{}, :id=>"76df9210b28c"}, ... , {:status=>"Status: Downloaded newer image for busybox:latest"}]

response.path
=> "/images/create?fromImage=busybox:latest"

response.success?
=> true
```

### Error handling

`Docker::API::InvalidParameter` and `Docker::API::InvalidRequestBody` may be raised when an invalid option is passed as argument (ie: an option not described in Docker API documentation for request query parameters nor request body (json) parameters). Even if no errors were raised, consider validating the status code and/or message of the response to check if the Docker daemon has fulfilled the operation properly.

To completely skip the validation process, add `:skip_validation => true` in the hash to be validated.

### Blocks

Some methods can receive a block to alter the default execution:
* Docker::API::Container#logs
* Docker::API::Container#attach
* Docker::API::Container#stats
* Docker::API::Container#export
* Docker::API::Container#get_archive
* Docker::API::Image#create
* Docker::API::Image#build
* Docker::API::Image#export
* Docker::API::System#event
* Docker::API::Exec#start
* Docker::API::Task#logs

Example:
```ruby
=> image = Docker::API::Image.new

=> image.create(fromImage: "nginx:alpine") do | chunk, bytes_remaining, bytes_total | 
        p chunk.to_s 
    end
```

The default blocks can be found in `Docker::API::Base`.

## Development

Run `rake spec` to run the tests. 

Run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Release new version

* Update README as needed.
* Update version.
* Run tests.
* Commit changes.
* Release / push version to Rubygems & Github.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nu12/dockerapi.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

