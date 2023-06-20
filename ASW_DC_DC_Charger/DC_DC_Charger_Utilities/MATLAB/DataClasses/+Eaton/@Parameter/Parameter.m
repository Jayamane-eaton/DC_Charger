classdef Parameter < mpt.Parameter
%Eaton.Parameter  Class definition.

  properties
    DisplayData = [];
    ConversionRule = [];
  end

  properties (PropertyType = 'char')
    DatabaseGrouping = '';
  end

  properties
    DisplayColor = [255, 0, 0];
  end

  properties (PropertyType = 'char')
    SecurityLevel = 'AllUsers';
    AxisDefinition = '';
    CoreInfo = '';
    AliasName = '';
    SpecialInstructions = '';
  end

  methods
    function setupCoderInfo(h)
      % Use custom storage classes from this package
      useLocalCustomStorageClasses(h, 'Eaton');
    end

    %---------------------------------------------------------------------------
    function h = Parameter(varargin)
      % ENTER CLASS INITIALIZATION CODE HERE (optional) ...
      
    end

  end % methods
end % classdef
