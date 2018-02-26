require File.expand_path(File.join(File.dirname(__FILE__), '..', 'postconf'))

Puppet::Type.type(:postconf).provide(:postconf, parent: Puppet::Provider::Postconf) do
  def self.instances
    postfix_instances.map { |instance, path|
      pc_output = postconf_multi((instance == '-') ? nil : path, '-n')

      pc_output.split("\n").map do |line|
        # unfortunately we need to parse stderr warnings here to handle unused/unknown parameters
        m = %r{^(?:\S+/postconf: warning: \S+/main.cf: unused parameter: )?([^=]+?) *= *(.*)$}.match(line)
        raise Error, 'Unexpected output from postconf: $line' unless m
        parameter, value = m[1..2]

        name = (instance == '-') ? parameter : "#{instance}::#{parameter}"

        prov = new(
          name: name,
          parameter: parameter,
          ensure: :present,
          value: value,
        )
        prov.config_dir = path
        prov
      end
    }.flatten
  end

  protected

  def entry_value
    raise ArgumentError, 'Value is a required property.' if resource[:value].nil?
    resource[:value].join(', ')
  end
end
