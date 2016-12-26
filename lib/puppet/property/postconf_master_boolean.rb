class Puppet::Property::PostconfMasterBoolean < Puppet::Property
  def unmunge(value)
    case value
    when :undef
      '-'
    when :true, :y
      'y'
    when :false, :n
      'n'
    end
  end

  def property_matches?(current, desired)
    current == unmunge(desired)
  end
end
