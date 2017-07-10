Facter.add(:postfix) do
  setcode do
    confine exists: 'postconf', for_binary: true

    configs = {
      :mail_version => :version,
      :config_directory => :default_config_directory,
      :data_directory => :default_data_directory,
    }

    facts = {}
    Facter::Core::Execution.execute("postconf -d -x #{configs.keys.join(' ')}").each_line do |line|
      parameter, value = line.chomp.split(%r{ *= *}, 2)
      facts[configs[parameter.to_sym]] = value
    end
    facts
  end
end

