require File.expand_path(File.join(File.dirname(__FILE__), '..', 'postconf'))

Puppet::Type.type(:postconf_master).provide(:postconf, parent: Puppet::Provider::Postconf) do
  confine postfixversion: '2.11'

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
                 "#{instance}::#{key}"
               end

        prov = new(
          name: name,
          ensure: :present,
          private: value[:private],
          unprivileged: value[:unprivileged],
          chroot: value[:chroot],
          wakeup: value[:wakeup],
          process_limit: value[:process_limit],
          command: value[:command]
        )
        prov.config_dir = rpath
        prov
      end
    end.flatten
  end

  protected

  def postconf(*args)
    super('-M', *args)
  end

  def entry_value
    raise ArgumentError, 'Command is a required property.' if resource[:command].nil?

    [
      resource.service_name,
      resource.service_type,
      resource[:private] || '-',
      resource[:unprivileged] || '-',
      resource[:chroot] || '-',
      resource[:wakeup] || '-',
      resource[:process_limit] || '-',
      resource[:command]
    ].join(' ')
  end

  private

  def self.postconf_master_hash(path = nil)
    opts = ['-F']
    opts += ['-c', path] if path

    pc_output = postconf_cmd(*opts).encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    pc_output.scan(%r{^(\S+\/\w+)\/(\w+) = (.*)$}).
      each_with_object({}) do |larray, hash|
        hash[larray[0]] ||= {}
        hash[larray[0]][larray[1].to_sym] = larray[2]
        hash
      end
  end
end
