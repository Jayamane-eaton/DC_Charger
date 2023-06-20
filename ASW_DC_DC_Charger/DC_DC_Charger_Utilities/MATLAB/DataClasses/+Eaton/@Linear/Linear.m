classdef Linear < handle
%Eaton.Linear  Class definition.

  % NOTE:
  % This class was originally defined in the Simulink data class designer
  % but it is not a subclass of a Simulink data class.  As a result, the
  % upgraded class cannot support the specification of property types.

  % Property type from data class designer: 'string'
  properties % (PropertyType = 'char')
    Description = '';
    DocUnits = '';
  end

  % Property type from data class designer: 'double'
  properties % (PropertyType = 'double scalar')
    Gain = 1;
    Offset = 0;
  end

end % classdef
