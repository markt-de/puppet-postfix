Puppet::Type.type(:postmulti).provide(:postmulti) do
  commands postmulti_cmd: 'postmulti'

  def self.instances
    postfix_instances.map { |instance, opts|
      next if instance == '-'

      new(
        name: instance,
        group: opts[:group],
        ensure: (opts[:active] == 'y') ? :active : :inactive,
      )
    }.compact
  end

  def self.prefetch(resources)
    pm = postfix_instances
    resources.each_value do |resource|
      next unless pm.key?(resource[:name])
      resource.provider = new(
        name:   resource[:name],
        group:  pm[resource[:name]][:group],
        ensure: (pm[resource[:name]][:active] == 'y') ? :active : :inactive,
      )
    end
  end

  def exists?
    [:active, :inactive].include? @property_hash[:ensure]
  end

  def create
    if resource[:group]
      postmulti_cmd('-e', 'create', '-I', resource[:name], '-G', resource[:group])
    else
      postmulti_cmd('-e', 'create', '-I', resource[:name])
    end
    @property_hash[:ensure] = :inactive
  end

  def activate
    create unless @property_hash[:ensure] == :inactive
    postmulti_cmd('-e', 'enable', '-i', resource[:name])
    @property_hash[:ensure] = :active
  end

  def deactivate
    create unless @property_hash[:ensure] == :active
    postmulti_cmd('-e', 'disable', '-i', resource[:name])
    @property_hash[:ensure] = :inactive
  end

  def destroy
    postmulti_cmd('-e', 'destroy', '-i', resource[:name])
    @property_hash.clear
  end

  mk_resource_methods

  def group
    @property_hash[:group]
  end

  def group=(name)
    @property_hash[:group] = name
    postmulti_cmd('-e', 'assign', '-i', resource[:name], '-G', name)
  end

  private

  def self.postfix_instances
    postmulti_cmd('-l').split("\n").each_with_object({}) do |line, i|
      line = line.split(%r{ +}, 4)
      i[line[0]] = {
        group: line[1],
        active: line[2],
        path: line[3],
      }
      i
    end
  end
end
