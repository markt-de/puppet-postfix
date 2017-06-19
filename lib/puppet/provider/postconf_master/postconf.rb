Puppet::Type.type(:postconf_master).provide(:postconf) do
  commands postmulti_cmd: 'postmulti'
  commands postconf_cmd: 'postconf'

  if command('postconf_cmd')
    confine true: begin
      postifx_version = postconf_cmd('-h', '-d', 'mail_version')
      Puppet::Util::Package.versioncmp(postifx_version, '2.11') >= 0
    end
  end

  def self.instances
    postfix_instances.map do |instance, path|
      rpath = if instance == '-'
                nil
              else
                path
              end
      postconf_master_hash(rpath).map do |key, value|
        name = if instance == '-'
                 key
               else
                 "#{path}:#{key}"
               end

        new(
          name: name,
          ensure: :present,
          service: value['service'],
          type: value['type'],
          private: value['private'],
          unprivileged: value['unprivileged'],
          chroot: value['chroot'],
          wakeup: value['wakeup'],
          process_limit: value['process_limit'],
          command: value['command'],
          config_dir: rpath
        )
      end
    end.flatten
  end

  def self.prefetch(resources)
    hash = {}
    resources.values.each do |resource|
      unless hash.key?(resource[:config_dir] || 'DEFAULT')
        hash[resource[:config_dir] || 'DEFAULT'] = postconf_master_hash(resource[:config_dir])
      end

      next unless hash[resource[:config_dir] || 'DEFAULT'].key?("#{resource[:service]}/#{resource[:type]}")

      rhash = hash[resource[:config_dir] || 'DEFAULT']["#{resource[:service]}/#{resource[:type]}"]

      resource.provider = new(
        ensure: :present,
        service: rhash['service'],
        type: rhash['type'],
        private: rhash['private'],
        unprivileged: rhash['unprivileged'],
        chroot: rhash['chroot'],
        wakeup: rhash['wakeup'],
        process_limit: rhash['process_limit'],
        command: rhash['command'],
        config_dir: resource[:config_dir]
      )
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    opts = ['-M']
    opts += ['-c', resource[:config_dir]] if resource[:config_dir]
    opts += ["#{resource[:service]}/#{resource[:type]}=#{resource.full_line}"]

    postconf_cmd(*opts)
    @property_hash[:ensure] = :present
  end

  def destroy
    opts = ['-MX']
    opts += ['-c', resource[:config_dir]] if resource[:config_dir]
    opts += ["#{resource[:service]}/#{resource[:type]}"]

    postconf_cmd(*opts)
    @property_hash.clear
  end

  mk_resource_methods

  def private=(should)
    opts = ['-F']
    opts += ['-c', resource[:config_dir]] if resource[:config_dir]
    opts += ["#{resource[:service]}/#{resource[:type]}/private=#{should}"]

    postconf_cmd(*opts)
    @property_hash[:private] = should
  end

  def unprivileged=(should)
    opts = ['-F']
    opts += ['-c', resource[:config_dir]] if resource[:config_dir]
    opts += ["#{resource[:service]}/#{resource[:type]}/unprivileged=#{should}"]

    postconf_cmd(*opts)
    @property_hash[:unprivileged] = should
  end

  def chroot=(should)
    opts = ['-F']
    opts += ['-c', resource[:config_dir]] if resource[:config_dir]
    opts += ["#{resource[:service]}/#{resource[:type]}/chroot=#{should}"]

    postconf_cmd(*opts)
    @property_hash[:chroot] = should
  end

  def wakeup=(should)
    opts = ['-F']
    opts += ['-c', resource[:config_dir]] if resource[:config_dir]
    opts += ["#{resource[:service]}/#{resource[:type]}/wakeup=#{should}"]

    postconf_cmd(*opts)
    @property_hash[:wakeup] = should
  end

  def process_limit=(should)
    opts = ['-F']
    opts += ['-c', resource[:config_dir]] if resource[:config_dir]
    opts += ["#{resource[:service]}/#{resource[:type]}/process_limit=#{should}"]

    postconf_cmd(*opts)
    @property_hash[:process_limit] = should
  end

  private

  def self.postfix_instances
    postmulti_cmd('-l').split("\n").each_with_object({}) do |line, i|
      line = line.split(%r{ +}, 4)
      i[line[0]] = line[3]
      i
    end
  end

  def self.postconf_master_hash(path = nil)
    opts = ['-F']
    opts += ['-c', path] if path

    pc_output = postconf_cmd(*opts).encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    pc_output.scan(%r{^(\S+)\/(\w+)\/(\w+) = (.*)$}).
      each_with_object({}) do |larray, hash|
        hash["#{larray[0]}/#{larray[1]}"] ||= {}
        hash["#{larray[0]}/#{larray[1]}"][larray[2]] = larray[3]
        hash
      end
  end
end
