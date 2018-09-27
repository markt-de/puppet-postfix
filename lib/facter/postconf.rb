Facter.add(:postfix) do
  setcode do
    postconf = Facter::Util::Resolution.which('postconf')
    if postconf.nil?
      next nil
    end

    configs = {
      mail_version: :version,
      config_directory: :default_config_directory,
      data_directory: :default_data_directory,
    }

    facts = {}
    Facter::Core::Execution.execute("#{postconf} -d -x #{configs.keys.join(' ')}").each_line do |line|
      parameter, value = line.chomp.split(%r{ *= *}, 2)
      facts[configs[parameter.to_sym]] = value
    end
    facts
  end
end
