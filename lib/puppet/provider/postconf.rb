require File.expand_path(File.join(File.dirname(__FILE__), '..', 'confine', 'postfix_version'))

# @summary Postfix postconf provider
class Puppet::Provider::Postconf < Puppet::Provider
  def self.initvars
    super

    commands postmulti_cmd: 'postmulti'
    commands postconf_cmd: 'postconf'
  end

  attr_writer :config_dir

  # Always make the resource methods.
  def self.resource_type=(resource)
    super
    mk_resource_methods
  end

  def self.prefetch(resources)
    provs = instances
    resources.each_key do |name|
      if (provider = provs.find { |p| p.name == name })
        resources[name].provider = provider
      end
    end
  end

  def initialize(*args)
    super(*args)

    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    write_entry

    @property_hash.clear
  end

  def self.postfix_instances
    postmulti_cmd('-l').split("\n").each_with_object({}) do |line, i|
      line = line.split(%r{ +}, 4)
      i[line[0]] = line[3]
      i
    end
  end

  def config_dir
    instance = resource.instance_name
    if instance.nil?
      nil
    else
      # Use the correct config_dir for this instance (if available).
      # This should usually work if `postmulti` was used to create
      # the instance.
      instance_config_dir = self.class.postfix_instances[instance]
      @config_dir ||= if instance_config_dir.nil?
                        # Fallback to value from default instance and add
                        # instance name to the path. This prevents accidential
                        # configuration changes to the main instance.
                        self.class.postfix_instances['-'] << "-#{instance}"
                      else
                        # Use the configured directory.
                        self.class.postfix_instances[instance]
                      end
    end
  end

  def self.postconf_multi(config_dir, *args)
    output =
      if config_dir
        postconf_cmd('-c', config_dir, *args)
      else
        postconf_cmd(*args)
      end
    return output.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') unless output.nil?
  end

  protected

  def write_entry
    if @property_flush[:ensure] == :absent
      postconf('-X', entry_key)
      return
    end

    postconf("#{entry_key}=#{entry_value}")
  end

  def entry_key
    resource[:name].rpartition('::')[2]
  end

  def entry_value
    raise Puppet::DevError, "Provider #{name} has not defined the 'entry_value' class method"
  end

  def postconf(*args)
    self.class.postconf_multi(config_dir, *args)
  end
end
