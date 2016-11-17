Puppet::Type.newtype(:postconf) do
  @doc = %q{Create a new postconf entry.

    Example:

        postconf { 'myhostname':
          value => 'foo.bar'
        }
  }

  ensurable

  newparam(:parameter, :namevar => true) do
    desc "The postconf parameter which should be set."

    validate do |value|
      unless value =~ /(^|:)[a-zA-Z0-9]+(?:_[a-zA-Z0-9]+)*$/
        raise ArgumentError, "Invalid value %s is not a valid postconf parameter name" % value
      end
    end
  end

  newproperty(:value, :array_matching => :all) do
    desc "The value the postconf parameter should be set to."

    def insync?(is)
      self.is_to_s(is) == self.should_to_s(@should)
    end

    def is_to_s(currentvalue)
      [currentvalue].flatten.join(', ')
    end

    def should_to_s(newvalue)
      [newvalue].flatten.join(', ')
    end

    validate do |value|
      if value.is_a? String
        return
      elsif value.is_a? Numeric
        return
      else
        raise ArgumentError, 'Invalid value %s is not a valid postconf value'
      end
    end
  end

  newproperty(:config_dir) do
    desc "Path to the postfix config_dir"
  end

  validate do
    if self[:ensure] == :present and self[:value] == nil
      self.fail 'Value is a required property.'
    end
  end

end
