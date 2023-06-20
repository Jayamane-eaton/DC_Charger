classdef Enum < handle
%Eaton.Enum  Class definition.

  % NOTE:
  % This class was originally defined in the Simulink data class designer
  % but it is not a subclass of a Simulink data class.  As a result, the
  % upgraded class cannot support the specification of property types.

  % Property type from data class designer: 'string'
  properties % (PropertyType = 'char')
    Description = '';
  end

  % Property type from data class designer: 'MATLAB array'
  properties
    EnumValues = [];
    EnumVals = [];
  end

  % Property type from data class designer: 'string'
  properties % (PropertyType = 'char')
    EnumList = '';
    Default = '';
  end

end % classdef
