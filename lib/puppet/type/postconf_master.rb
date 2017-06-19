Puppet::Type.newtype(:postconf_master) do
  @doc = "Create a new postconf master.cf entry.

    Example:

        postconf_master { 'smtp/inet':
          command => 'postscreen'
        }
  "

  ensurable

  class PostconfMasterBoolean < Puppet::Property
    def unmunge(value)
      case value
      when :undef
        '-'
      when :true, :y
        'y'
      when :false, :n
        'n'
      end
    end

    def property_matches?(current, desired)
      current == unmunge(desired)
    end
  end

  class PostconfMasterString < Puppet::Property
    def unmunge(value)
      case value
      when :undef
        '-'
      else
        value
      end
    end

    def property_matches?(current, desired)
      current == unmunge(desired)
    end
  end

  newproperty(:name, namevar: true) do
  end

  newproperty(:service, namevar: true) do
    desc 'The postconf master.cf service which should be managed.'
  end

  newproperty(:type, namevar: true) do
    desc 'The postconf master.cf type which should be managed.'

    newvalues(:inet, :unix, :fifo, :pipe, :pass)
  end

  newproperty(:private, parent: PostconfMasterBoolean) do
    desc 'Whether or not access is restricted to the mail system.'
    defaultto :undef

    newvalues(:true, :false, :undef, :y, :n)
  end

  newproperty(:unprivileged, parent: PostconfMasterBoolean) do
    desc 'Whether the service runs with root privileges or as the owner of the  Postfix  system.'
    defaultto :undef

    newvalues(:true, :false, :undef, :y, :n)
  end

  newproperty(:chroot, parent: PostconfMasterBoolean) do
    desc 'Whether or not the service  runs  chrooted  to  the  mail  queue directory.'
    defaultto :undef

    newvalues(:true, :false, :undef, :y, :n)
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

  newproperty(:config_dir) do
    desc 'Path to the postfix config_dir'
  end

  validate do
    if (self[:ensure] == :present) && self[:command].nil?
      raise ArgumentError, 'Command is a required property.'
    end

    case self[:type]
    when :inet
      unless self[:service] =~ %r{^(?:(?:\[[a-zA-Z0-9.:]+\]|[a-zA-Z0-9.]+):)?[a-zA-Z0-9]+$}
        raise ArgumentError,
              format('Invalid service %s is not a valid postconf master service inet name',
                     self[:service])
      end
    when :unix, :fifo, :pipe, :pass
      unless self[:service] =~ %r{^[a-zA-Z0-9._/-]+}
        raise ArgumentError,
              format('Invalid service %s is not a valid postconf master service unix socket name',
                     self[:service])
      end
    else
      raise ArgumentError, format("Invalid type %s", self[:type])
    end
  end

  def self.title_patterns
    [
      [%r{^(.+)/([a-z]+)$}, [[:service], [:type]]],
    ]
  end

  def full_line
    [
      self[:service],
      self[:type],
      self[:private],
      self[:unprivileged] || '-',
      self[:chroot] || '-',
      self[:wakeup] || '-',
      self[:process_limit] || '-',
      self[:command]
    ].join(' ')
  end
end
