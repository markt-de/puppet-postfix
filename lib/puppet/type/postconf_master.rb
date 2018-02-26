Puppet::Type.newtype(:postconf_master) do
  @doc = "Create a new postconf master.cf entry.

   Puppet does not really support generating/prefetching resources with multiple
   namevars, so this type represents the whole service identifier in the :name
   property. This includes the postmulti instance.
   Valid formats are:
     * service/type
     * instance::service/type


    **Autorequires:** If Puppet is managing the postmulti instance for this entry,
    it will be autorequired.

    Example:

        postconf_master { 'smtp/inet':
          command => 'postscreen'
        }
  "

  ensurable

  class PostconfMasterBoolean < Puppet::Property
    def unsafe_munge(value)
      # downcase strings
      if value.respond_to? :downcase
        value = value.downcase
      end

      case value
      when :undef, '-', nil
        '-'
      when true, :true, 'true', :yes, 'yes', :y, 'y'
        'y'
      when false, :false, 'false', :no, 'no', :n, 'n'
        'n'
      else
        raise ArgumentError, "Invalid value #{value.inspect}. Valid values are true, false, y, n, -."
      end
    end
  end

  class PostconfMasterString < Puppet::Property
    def unsafe_munge(value)
      case value
      when :undef
        '-'
      else
        value.to_s
      end
    end
  end

  newparam(:name, namevar: true) do
    desc 'The postconf master.cf service/type which should be managed.'

    newvalues(
      %r{^
        (postfix-[^/]*::)?                           # optional postmulti instance name
        (
          (( \[[a-zA-Z0-9.:]+\] | [a-zA-Z0-9.]+ ):)? # optional interface address for inet types
          [a-zA-Z0-9]+/inet                          # (named/numeric) port and inet type
        |
          [a-zA-Z0-9._/-]+/(unix|fifo|pipe|pass)     # all other services can have socket paths
        )$}mx
    )
  end

  newproperty(:private, parent: PostconfMasterBoolean) do
    desc 'Whether or not access is restricted to the mail system.'
    defaultto :undef
  end

  newproperty(:unprivileged, parent: PostconfMasterBoolean) do
    desc 'Whether the service runs with root privileges or as the owner of the  Postfix  system.'
    defaultto :undef
  end

  newproperty(:chroot, parent: PostconfMasterBoolean) do
    desc 'Whether or not the service  runs  chrooted  to  the  mail  queue directory.'
    defaultto :undef
  end

  newproperty(:wakeup, parent: PostconfMasterString) do
    desc 'Automatically wake up the named service after the specified number of seconds.'
    defaultto :undef

    newvalues(:undef, %r{^\d+\??$})
  end

  newproperty(:process_limit, parent: PostconfMasterString) do
    desc 'The maximum number of processes that may  execute  this  service simultaneously.'
    defaultto :undef

    newvalues(:undef, %r{^\d+$})
  end

  newproperty(:command) do
    desc 'The command to be executed.'
  end

  def instance_name
    instance = self[:name].rpartition('::')[0]
    return nil if instance.empty?
    instance
  end

  def service
    self[:name].rpartition('::')[2]
  end

  def service_name
    service.rpartition('/')[0]
  end

  def service_type
    service.rpartition('/')[2]
  end

  autorequire(:postmulti) do
    instance_name
  end
end
