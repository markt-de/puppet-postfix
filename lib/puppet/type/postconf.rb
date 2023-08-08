# @summary Type to manage postconf parameters.
Puppet::Type.newtype(:postconf) do
  @doc = "Create a new postconf entry.

   Puppet does not really support generating/prefetching resources with multiple
   namevars, so this type represents the whole parameter identifier in the :parameter
   property. This includes the postmulti instance.
   Valid formats are:
     * service/type
     * instance::service/type

    **Autorequires:** If Puppet is managing the postmulti instance for this entry,
    it will be autorequired.


    Example:

        postconf { 'myhostname':
          value => 'foo.bar'
        }
  "

  ensurable

  newparam(:parameter, namevar: true) do
    desc 'The postconf parameter which should be set.'

    newvalues(%r{^([^/]+::)?[a-zA-Z0-9]+(?:_[a-zA-Z0-9]+)*$})
  end

  newproperty(:value, array_matching: :all) do
    desc 'The value the postconf parameter should be set to.'

    def insync?(is)
      is_to_s(is) == should_to_s(@should)
    end

    # rubocop:disable Naming/PredicateName
    def is_to_s(currentvalue)
      [currentvalue].flatten.join(', ')
    end
    # rubocop:enable Naming/PredicateName

    def should_to_s(newvalue)
      [newvalue].flatten.join(', ')
    end

    validate do |value|
      return if value.is_a?(String) || value.is_a?(Numeric)

      raise ArgumentError, 'Invalid value %s is not a valid postconf value'
    end
  end

  def instance_name
    instance = self[:name].rpartition('::')[0]
    return nil if instance.empty?
    instance
  end

  def parameter_name
    self[:name].rpartition('::')[2]
  end

  autorequire(:postmulti) do
    instance_name
  end
end
