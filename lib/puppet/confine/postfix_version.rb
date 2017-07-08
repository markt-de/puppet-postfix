require 'puppet/util'
require 'puppet/confine'

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
    unless @postfix_version
      begin
        @postfix_version = Puppet::Util::Execution.execute(
          [Puppet::Util.which('postconf'), '-h', '-d', 'mail_version'],
          failonfail: true
        ).chomp
      rescue
        @postfix_version = :absent
        raise
      end
    end

    @postfix_version
  end
end
