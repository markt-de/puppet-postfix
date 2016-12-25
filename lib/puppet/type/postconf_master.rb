Puppet::Type.newtype(:postconf_master) do
  @doc = "Create a new postconf master.cf entry.

    Example:

        postconf_master { 'smtp/inet':
          command => 'postscreen'
        }
  "

  ensurable

  newparam(:service, namevar: true) do
    desc 'The postconf master.cf service which should be managed.'

    validate do |value|
      unless value =~ %r{^[a-zA-Z0-9]+$}
        raise ArgumentError,
              format('Invalid service %s is not a valid postconf master service name',
                     value)
      end
    end
  end

  newparam(:type, namevar: true) do
    desc 'The postconf master.cf type which should be managed.'

    newvalues(:inet, :unix, :fifo, :pipe)
  end

  newparam(:private) do
    desc 'Whether or not access is restricted to the mail system.'
    defaultto :undef

    newvalues(:true, :false, :undef, :y, :n)

    unmunge do |value|
      case value
      when :undef
        '-'
      when :true, :y
        'y'
      when :false, :n
        'n'
      end
    end
  end

  newparam(:unprivileged) do
    desc 'Whether the service runs with root privileges or as the owner of the  Postfix  system.'
    defaultto :undef

    newvalues(:true, :false, :undef, :y, :n)

    unmunge do |value|
      case value
      when :undef
        '-'
      when :true, :y
        'y'
      when :false, :n
        'n'
      end
    end
  end

  newparam(:chroot) do
    desc 'Whether or not the service  runs  chrooted  to  the  mail  queue directory.'
    defaultto :undef

    newvalues(:true, :false, :undef, :y, :n)

    unmunge do |value|
      case value
      when :undef
        '-'
      when :true, :y
        'y'
      when :false, :n
        'n'
      end
    end
  end

  newparam(:wakeup) do
    desc 'Automatically wake up the named service after the specified number of seconds.'
    defaultto :undef

    newvalues(:undef, %r{^\d+\??$})

    unmunge do |value|
      case value
      when :undef
        '-'
      else
        value
      end
    end
  end

  newparam(:process_limit) do
    desc 'The maximum number of processes that may  execute  this  service simultaneously.'
    defaultto :undef

    newvalues(:undef, %r{^\d+$})

    unmunge do |value|
      case value
      when :undef
        '-'
      else
        value
      end
    end
  end

  newparam(:command) do
    desc 'The command to be executed.'
  end

  newproperty(:config_dir) do
    desc 'Path to the postfix config_dir'
  end

  validate do
    if (self[:ensure] == :present) && self[:command].nil?
      raise 'Value is a required property.'
    end
  end

  def self.title_patterns
    [
      [%r{^([a-zA-Z0-9]+)/([a-z]+)$}, [[:service], [:type]]]
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
