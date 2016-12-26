class Puppet::Property::PostconfMasterString < Puppet::Property
  def unmunge(value)
    case value
    when :undef
      '-'
    else
      value
    end
  end

  def property_matches?(current, desired)
    current == unmunge(desired)
  end
end
