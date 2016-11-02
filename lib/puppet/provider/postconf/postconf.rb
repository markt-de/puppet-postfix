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
    hash = {}
    resources.values.each do |resource|
      unless hash.has_key?(resource[:config_dir] || 'DEFAULT')
        hash[resource[:config_dir] || 'DEFAULT'] = postconf_hash(resource[:config_dir])
      end

      if hash[resource[:config_dir] || 'DEFAULT'].has_key?(resource[:parameter])
        resource.provider = new(
          parameter:  resource[:parameter],
          ensure:     :present,
          value:      hash[resource[:config_dir] || 'DEFAULT'][resource[:parameter]],
          config_dir: resource[:config_dir] || nil
        )
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

  def value
    @property_hash[:value]
  end

  def value=(value)
    @property_hash[:value] = value
    create
  end

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

  def self.postconf_hash(path=nil)
    opts = ['-n']
    if path
      opts += ['-c', path]
    end

    pc_output = postconf_cmd(*opts).encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')

    pc_output.split("\n").inject({}) do |hash, line|
      parameter, value = line.split(/ *= */, 2)
      hash[parameter] = value
      hash
    end
  end

end
