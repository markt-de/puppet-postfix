require File.expand_path(File.join(File.dirname(__FILE__), '..', 'postconf'))

Puppet::Type.type(:postconf_master).provide(:postconf, parent: Puppet::Provider::Postconf) do

  def self.instances
    postfix_instances.map { |instance, path|
      rpath = (instance == '-') ? nil : path
      postconf_master_hash(rpath).map do |key, value|
        name = (instance == '-') ? key : "#{instance}::#{key}"

        prov = new(
          name: name,
          ensure: :present,
          private: value[:private],
          unprivileged: value[:unprivileged],
          chroot: value[:chroot],
          wakeup: value[:wakeup],
          process_limit: value[:process_limit],
          command: value[:command],
        )
        prov.config_dir = rpath
        prov
      end
    }.flatten
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
      resource[:command],
    ].join(' ')
  end

  private

  def self.postconf_master_hash(path = nil)
    pc_output = postconf_multi(path, '-F')

    pc_output.scan(%r{^(\S+\/\w+)\/(\w+) = (.*)$}).each_with_object({}) do |larray, hash|
      hash[larray[0]] ||= {}
      hash[larray[0]][larray[1].to_sym] = larray[2]
      hash
    end
  end
end
