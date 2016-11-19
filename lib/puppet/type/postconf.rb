Puppet::Type.newtype(:postconf) do
  @doc = "Create a new postconf entry.

    Example:

        postconf { 'myhostname':
          value => 'foo.bar'
        }
  "

  ensurable

  newparam(:parameter, namevar: true) do
    desc 'The postconf parameter which should be set.'

    validate do |value|
      unless value =~ %r{(^|:)[a-zA-Z0-9]+(?:_[a-zA-Z0-9]+)*$}
        raise ArgumentError,
              format('Invalid value %s is not a valid postconf parameter name',
                     value)
      end
    end
  end

  newproperty(:value, array_matching: :all) do
    desc 'The value the postconf parameter should be set to.'

    def insync?(is)
      is_to_s(is) == should_to_s(@should)
    end

    # rubocop:disable Style/PredicateName
    def is_to_s(currentvalue)
      [currentvalue].flatten.join(', ')
    end
    # rubocop:enable Style/PredicateName

    def should_to_s(newvalue)
      [newvalue].flatten.join(', ')
    end

    validate do |value|
      return if value.is_a?(String) || value.is_a?(Numeric)

      raise ArgumentError, 'Invalid value %s is not a valid postconf value'
    end
  end

  newproperty(:config_dir) do
    desc 'Path to the postfix config_dir'
  end

  validate do
    if (self[:ensure] == :present) && self[:value].nil?
      raise 'Value is a required property.'
    end
  end
end
