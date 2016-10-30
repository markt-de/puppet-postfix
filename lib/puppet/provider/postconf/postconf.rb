Puppet::Type.type(:postconf).provide(:postconf) do

  commands :postconf => 'postconf'

  def self.instances
    pc_output = postconf('-n').encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')

    pc_output.split("\n").collect do |line|

      key, value = line.split(/ *= */, 2)

      new(
        :name   => key,
        :ensure => :present,
        :value  => value
      )
    end
  end

  def self.prefetch(resources)
    pc = instances
    resources.keys.each do |name|
      if provider = pc.find { |pc| pc.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    postconf("#{resource[:parameter]}=#{resource[:value]}")
    @property_hash[:ensure] = :present
  end

  def destroy
    postconf('-X', resource[:parameter])
    @property_hash.clear
  end

  mk_resource_methods

end
