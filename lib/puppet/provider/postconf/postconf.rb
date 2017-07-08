require 'puppet/provider/postconf'

Puppet::Type.type(:postconf).provide(:postconf, parent: Puppet::Provider::Postconf) do

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
                 "#{instance}::#{parameter}"
               end

        prov = new(
          name: name,
          parameter: parameter,
          ensure: :present,
          value: value
        )
        prov.config_dir = path
        prov
      end
    end.flatten
  end

  protected

  def entry_value
    raise ArgumentError, 'Value is a required property.' if resource[:value].nil?
    resource[:value].join(', ')
  end

  private

  # split strings at [, ] while keeping {}-groups, mimicking postfix' mystrtokq function
  def self.split_grouped(s)
    s.to_enum(:scan, %r{\G(?<match>(?<grouped>\{(?:[^{}]*|(?:\g<grouped>))*\})|[^, ]+)[, ]*}).map { |x| x[0] }
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
