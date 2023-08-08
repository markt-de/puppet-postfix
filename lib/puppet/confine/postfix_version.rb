require 'puppet/util'
require 'puppet/confine'

# @summary Provide the Postfix version
class Puppet::Confine::PostfixVersion < Puppet::Confine
  def self.summarize(confines)
    confines.map(&:values).flatten.uniq.reject { |value| confines[0].pass?(value) }
  end

  def pass?(value)
    postfix_version = self.class.postfix_version
    return false if postfix_version == :absent
    Puppet::Util::Package.versioncmp(postfix_version, value) >= 0
  end

  def message(value)
    "postfix version >= #{value} required (have #{self.class.postfix_version})"
  end

  def self.postfix_version
    postfix_facts = Facter.value(:postfix)
    return :absent if postfix_facts.nil?
    postfix_version = postfix_facts[:version]
    postfix_version.nil? ? :absent : postfix_version
  end
end
