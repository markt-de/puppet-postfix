Puppet::Type.type(:postconf).provide(:postconf) do

  commands :postmulti_cmd => 'postmulti'
  commands :postconf_cmd => 'postconf'

  def self.instances

    postfix_instances.collect do |instance,path|

      if instance == '-'
        pc_output = postconf_cmd('-n').encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')
      else
        pc_output = postconf_cmd('-n', '-c', path).encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')
      end

      pc_output.split("\n").collect do |line|
        parameter, value = line.split(/ *= */, 2)

        name = if instance == '-'
                 parameter
               else
                 "#{instance}:#{parameter}"
               end

        new(
          :name       => name,
          :parameter  => parameter,
          :ensure     => :present,
          :value      => value,
          :config_dir => path,
        )
      end

    end.flatten

  end

  def self.prefetch(resources)
    pc = instances
    resources.values.each do |resource|
      if provider = pc.find { |pc| pc.parameter == resource[:parameter] and pc.config_dir == resource[:config_dir] }
        resource.provider = provider
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

  private

  def postconf(*args)
    if resource[:config_dir]
      postconf_cmd('-c', resource[:config_dir], *args)
    else
      postconf_cmd(*args)
    end
  end

  def self.postfix_instances
    postmulti_cmd('-l').split("\n").inject({}) do |i, line|
      line = line.split(/ +/, 4)
      i[line[0]] = line[3]
      i
    end
  end

end
