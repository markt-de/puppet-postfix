Puppet::Type.type(:postconf).provide(:postconf) do
  commands postmulti_cmd: 'postmulti'
  commands postconf_cmd: 'postconf'

  def self.instances
    postfix_instances.map do |instance, path|
      pc_output = if instance == '-'
                    postconf_cmd('-n').encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
                  else
                    postconf_cmd('-n', '-c', path).encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
                  end

      pc_output.split("\n").map do |line|
        parameter, value = line.split(%r{ *= *}, 2)

        name = if instance == '-'
                 parameter
               else
                 "#{instance}:#{parameter}"
               end

        new(
          name: name,
          parameter: parameter,
          ensure: :present,
          value: value,
          config_dir: path
        )
      end
    end.flatten
  end

  def self.prefetch(resources)
    hash = {}
    resources.values.each do |resource|
      unless hash.key?(resource[:config_dir] || 'DEFAULT')
        hash[resource[:config_dir] || 'DEFAULT'] = postconf_hash(resource[:config_dir])
      end

      next unless hash[resource[:config_dir] || 'DEFAULT'].key?(resource[:parameter])
      value = hash[resource[:config_dir] || 'DEFAULT'][resource[:parameter]]
      value = split_grouped(value) unless !resource[:value] || resource[:value].size == 1
      resource.provider = new(
        parameter:  resource[:parameter],
        ensure:     :present,
        value:      value,
        config_dir: resource[:config_dir] || nil
      )
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    postconf("#{resource[:parameter]}=#{resource[:value].join(', ')}")
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

  # split strings at [, ] while keeping {}-groups, mimicking postfix' mystrtokq function
  def self.split_grouped(s)
    s.to_enum(:scan, /\G(?<match>(?<grouped>\{(?:[^{}]*|(?:\g<grouped>))*\})|[^, ]+)[, ]*/).map { |x| x[0] }
  end

  def self.postfix_instances
    postmulti_cmd('-l').split("\n").each_with_object({}) do |line, i|
      line = line.split(%r{ +}, 4)
      i[line[0]] = line[3]
      i
    end
  end

  def self.postconf_hash(path = nil)
    opts = ['-n']
    opts += ['-c', path] if path

    pc_output = postconf_cmd(*opts).encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    pc_output.split("\n").each_with_object({}) do |line, hash|
      parameter, value = line.split(%r{ *= *}, 2)
      hash[parameter] = value
      hash
    end
  end
end
