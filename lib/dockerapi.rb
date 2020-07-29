require "excon"
require "json"
require "base64"
require "fileutils"

require "docker/api/version"
require "docker/api/error"
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

    VALID_PARAMS = {
      "Docker::API::Image" => {
        "build" => [:dockerfile, :t, :extrahosts, :remote, :q, :nocache, :cachefrom, :pull, :rm, :forcerm, :memory, :memswap, :cpushares, :cpusetcpus, :cpuperiod, :cpuquota, :buildargs, :shmsize, :squash, :labels, :networkmode, :platform, :target, :outputs],
        "prune" => [:filters],
        "list" => [:all, :filters, :digests],
        "search" => [:term, :limit, :filters],
        "tag" => [:repo, :tag],
        "remove" => [:force, :noprune],
        "import" => [:quiet],
        "push" => [:tag],
        "commit" => [:container, :repo, :tag, :comment, :author, :pause, :changes],
        "create" => [:fromImage, :fromSrc, :repo, :tag, :message, :platform],
        "delete_cache" => [:all, "keep-storage", :filters]
      },
      "Docker::API::Container" => {
        "list" => [:all, :limit, :size, :filters],
        "details" => [:size],
        "top" => [:ps_args],
        "start" => [:detachKeys],
        "stop" => [:t],
        "restart" => [:t],
        "kill" => [:signal],
        "wait" => [:condition],
        "rename" => [:name],
        "resize" => [:w, :h],
        "prune" => [:filters],
        "remove" => [:v, :force, :link],
        "logs" => [:follow, :stdout, :stderr, :since, :until, :timestamps, :tail],
        "attach" => [:detachKeys, :logs, :stream, :stdin, :stdout, :stderr],
        "stats" => [:stream],
        "archive" => [:path, :noOverwriteDirNonDir, :copyUIDGID],
        "create" => [:name]
      },
      "Docker::API::Volume" => {
        "list" => [:filters],
        "remove" => [:force],
        "prune" => [:filters]
      },
      "Docker::API::Network" => {
        "list" => [:filters],
        "details" => [:verbose, :scope],
        "prune" => [:filters]
      },
      "Docker::API::System" => {
        "events" => [:since, :until, :filters]
      },
      "Docker::API::Exec" => {
        "resize" => [:w, :h]
      },
      "Docker::API::Swarm" => {
        "leave" => [:force],
        "update" => [:version, :rotateWorkerToken, :rotateManagerToken, :rotateManagerUnlockKey]
      },
      "Docker::API::Node" => {
        "list" => [:filters],
        "update" => [:version],
        "delete" => [:force]
      },
      "Docker::API::Service" => {
        "list" => [:filters],
        "update" => [:version, :registryAuthFrom, :rollback],
        "details" => [:insertDefaults],
        "logs" => [:details, :follow, :stdout, :stderr, :since, :timestamps, :tail]
      },
      "Docker::API::Secret" => {
        "list" => [:filters],
        "update" => [:version]
      },
      "Docker::API::Task" => {
        "list" => [:filters],
        "logs" => [:details, :follow, :stdout, :stderr, :since, :timestamps, :tail]
      },
      "Docker::API::Plugin" => {
        "list" => [:filters],
        "privileges" => [:remote],
        "install" => [:remote, :name],
        "remove" => [:force],
        "enable" => [:timeout],
        "upgrade" => [:remote]
      },
      "Docker::API::Config" => {
        "list" => [:filters],
        "update" => [:version]
      }
    }

    VALID_BODY = {
      "Docker::API::Image" => {
        "commit" => [:Hostname, :Domainname, :User, :AttachStdin, :AttachStdout, :AttachStderr, :ExposedPorts, :Tty, :OpenStdin, :StdinOnce, :Env, :Cmd, :HealthCheck, :ArgsEscaped, :Image, :Volumes, :WorkingDir, :Entrypoint, :NetworkDisabled, :MacAddress, :OnBuild, :Labels, :StopSignal, :StopTimeout, :Shell]
      },
      "Docker::API::Container" => {
        "create" => [:Hostname,:Domainname,:User,:AttachStdin,:AttachStdout,:AttachStderr,:ExposedPorts,:Tty,:OpenStdin,:StdinOnce,:Env,:Cmd,:HealthCheck,:ArgsEscaped,:Image,:Volumes,:WorkingDir,:Entrypoint,:NetworkDisabled,:MacAddress,:OnBuild,:Labels,:StopSignal,:StopTimeout,:Shell,:HostConfig,:NetworkingConfig],
        "update" => [:CpuShares, :Memory, :CgroupParent, :BlkioWeight, :BlkioWeightDevice, :BlkioWeightReadBps, :BlkioWeightWriteBps, :BlkioWeightReadOps, :BlkioWeightWriteOps, :CpuPeriod, :CpuQuota, :CpuRealtimePeriod, :CpuRealtimeRuntime, :CpusetCpus, :CpusetMems, :Devices, :DeviceCgroupRules, :DeviceRequest, :Kernel, :Memory, :KernelMemoryTCP, :MemoryReservation, :MemorySwap, :MemorySwappiness, :NanoCPUs, :OomKillDisable, :Init, :PidsLimit, :ULimits, :CpuCount, :CpuPercent, :IOMaximumIOps, :IOMaximumBandwidth, :RestartPolicy]
      },
      "Docker::API::Volume" => {
        "create" => [:Name, :Driver, :DriverOpts, :Labels]
      },
      "Docker::API::Network" => {
        "create" => [:Name, :CheckDuplicate, :Driver, :Internal, :Attachable, :Ingress, :IPAM, :EnableIPv6, :Options, :Labels],
        "connect" => [:Container, :EndpointConfig],
        "disconnect" => [:Container, :Force]
      },
      "Docker::API::System" => {
        "auth" => [:username, :password, :email, :serveraddress, :identitytoken]
      },
      "Docker::API::Exec" => {
        "create" => [:AttachStdin, :AttachStdout, :AttachStderr, :DetachKeys, :Tty, :Env, :Cmd, :Privileged, :User, :WorkingDir],
        "start" => [:Detach, :Tty]
      },
      "Docker::API::Swarm" => {
        "init" => [:ListenAddr, :AdvertiseAddr, :DataPathAddr, :DataPathPort, :DefaultAddrPool, :ForceNewCluster, :SubnetSize, :Spec],
        "update" => [:Name, :Labels, :Orchestration, :Raft, :Dispatcher, :CAConfig, :EncryptionConfig, :TaskDefaults],
        "unlock" => [:UnlockKey],
        "join" => [:ListenAddr, :AdvertiseAddr, :DataPathAddr, :RemoteAddrs, :JoinToken]
      },
      "Docker::API::Node" => {
        "update" => [:Name, :Labels, :Role, :Availability]
      },
      "Docker::API::Service" => {
        "create" => [:Name, :Labels, :TaskTemplate, :Mode, :UpdateConfig, :RollbackConfig, :Networks, :EndpointSpec],
        "update" => [:Name, :Labels, :TaskTemplate, :Mode, :UpdateConfig, :RollbackConfig, :Networks, :EndpointSpec]
      },
      "Docker::API::Secret" => {
        "create" => [:Name, :Labels, :Data, :Driver, :Templating],
        "update" => [:Name, :Labels, :Data, :Driver, :Templating]
      },
      "Docker::API::Config" => {
        "create" => [:Name, :Labels, :Data, :Templating],
        "update" => [:Name, :Labels, :Data, :Driver, :Templating]
      }
    }
    
  end
end
