# 0.14.0

Method `Docker::API::Container#archive` is splitted in `#get_archive` and `#put_archive` as per Docker API documentation.

The following `Docker::API::Container` methods that can now receive a block:
* logs (output to stdout)
* attach (output to stdout)
* stats (output to stdout)
* export (write file)
* get_archive (write file)

# 0.13.0

Add default behavior for file read, write and output to stdout. Whenever a method can receive a block, this default behavior can be replaced.

The following `Docker::API::Image` methods that can now receive a block:
* export (write file)
* create (output to stdout)
* build (output to stdout)

Default output to stdout can be supressed by setting `Docker::API::PRINT_TO_STDOUT` to `false`

Method parameters `params` and `body` will be automatically evaluated whenever they are present in the method's signature.

# 0.12.0

Add `Docker::API::Plugin` methods:
* list
* privileges
* install
* details
* remove
* enable
* disable
* upgrade
* create
* push
* configure

# 0.11.0

Add `Docker::API::Task` methods:
* list
* details
* logs

Add `Docker::API::Secret` methods:
* create
* update
* list
* details
* delete

Add `Docker::API::Config` methods:
* create
* update
* list
* details
* delete

Add `Docker::API::Image` methods:
* distribution

# 0.10.0

Add `Docker::API::Service` methods:
* create
* update
* list
* details
* logs
* delete

# 0.9.0

Significant change: `#inspect` is now deprecated and replaced by `#details` in the following classes:
* `Docker::API::Container`
* `Docker::API::Image`
* `Docker::API::Network`
* `Docker::API::Volume`
* `Docker::API::Exec`
* `Docker::API::Swarm`
* `Docker::API::Node`

The method will be removed in the refactoring phase.

# 0.8.1

Restore the default `#inspect` output for `Docker::API` classes. 

Most of the overriding methods take an argument, therefore calling using the expect arguments will return a `Docker::API::Response` object, while calling without arguments will return `Kernel#inspect`. To avoid this confusing schema, next release will rename `#inspect` within `Docker::API` to something else.

# 0.8.0

Add `Docker::API::Swarm` methods:
* init
* update
* ~~inspect~~ details
* unlock_key
* unlock
* join
* leave

Add `Docker::API::Node` methods:
* list
* ~~inspect~~ details
* update
* delete

Query parameters and request body json can now skip the validation step with `:skip_validation => true` option.

# 0.7.0

Significant changes: `Docker::API::Connection` is now a regular class intead of a Singleton, allowing multiple connections to be stablished within the same program (replacing the connect_to implementation). To leverage this feature, API-related classes must be initialized and may or may not receive a `Docker::API::Connection` as parameter, or it'll connect to `/var/run/docker.sock` by default. For this reason, class methods were replaced with instance methods. Documentation will reflect this changes of implementation.

Bug fix: Image push returns a 20X status even when the push is unsucessful. To prevent false positives, it now requires the authentication parameters to be provided, generating a 403 status for invalid credentials or an error if they are absent.

# 0.6.0

Add connection parameters specifications with connect_to in Docker::API::Connection.

Add `Docker::API::Exec` methods:
* create
* start
* resize
* ~~inspect~~ details

# 0.5.0

Add `Docker::API::System` methods:
* auth
* ping
* info
* version
* events
* df

Add new response class `Docker::API::Response` with the following methods:
* json
* path
* success?

Error classes output better error messages.

# 0.4.0

Add `Docker::API::Network` methods:
* list
* ~~inspect~~ details
* create
* remove
* prune
* connect
* disconnect

# 0.3.0

Add `Docker::API::Volume` methods:
* list
* ~~inspect~~ details
* create
* remove
* prune


# 0.2.0

Add `Docker::API::Image` methods:
* ~~inspect~~ details
* history
* list
* search
* tag
* prune
* remove
* export
* import
* push
* commit
* create
* build
* delete_cache

Add `Docker::API::System.auth` (untested) for basic authentication

# 0.1.0

Add `Docker::API::Container` methods:
* list
* ~~inspect~~ details
* top
* changes
* start
* stop
* restart
* kill
* wait
* update
* rename
* resize
* prune
* pause
* unpause
* remove
* logs
* attach
* create
* stats
* export
* archive