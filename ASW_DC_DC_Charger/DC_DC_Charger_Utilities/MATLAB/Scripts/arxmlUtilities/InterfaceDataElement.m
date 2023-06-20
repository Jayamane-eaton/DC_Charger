classdef InterfaceDataElement < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        calAccess
        SWImpPolicy
        dataType
        initValue
        comSpec
    end
    
    methods
        %% construtor 
        function obj = InterfaceDataElement(package,name)
            %Constructor of class
            obj.package = package;
            obj.name = name;

        end
        
        %% getter setters
        function set.package(obj,string)
            %setter for property package
            if(~isempty(string))
                obj.package = string;
            else
                disp(['Warning: trying to assign empty string to propery "package" of object: ',obj.name])
            end
        end
        

        function val = get.package(obj)
            %getter for property package
            if(~isempty(obj.name))
                val = obj.package;
            else
                val = obj.package;
            end
        end
        
        function set.name(obj,string)
            %setter for property name
            if(~isempty(string))
                obj.name = string;
            else
                disp(['Warning: trying to assign empty string to propery "name" of object: ',obj.name])
            end
        end
        
        function val = get.name(obj)
            %getter
            if(~isempty(obj.name))
                val = obj.name;
            else
                val = obj.name;
            end
        end
        
         function set.calAccess(obj,string)
            %setter for property calAccess
            if(~isempty(string))
                obj.calAccess = string;
            else
                disp(['Warning: trying to assign empty string to propery "calAccess" of object: ',obj.name])
            end
        end
        
        function val = get.calAccess(obj)
            %getter for property calAccess
            if(~isempty(obj.calAccess))
                val = obj.calAccess;
            else
                val = obj.calAccess;
            end
        end

        function set.SWImpPolicy(obj,string)
            %setter for property SWImpPolicy
            if(~isempty(string))
                obj.SWImpPolicy = string;
            else
                disp(['Warning: trying to assign empty string to propery "SWImpPolicy" of object: ',obj.name])
            end
        end
        
        function val = get.SWImpPolicy(obj)
            %getter for property SWImpPolicy
            if(~isempty(obj.SWImpPolicy))
                val = obj.SWImpPolicy;
            else
                val = obj.SWImpPolicy;
            end
        end
        
       function set.dataType(obj,string)
            %setter for property dataType
            if(~isempty(string))
                obj.dataType = string;
            else
                disp(['Warning: trying to assign empty string to propery "dataType" of object: ',obj.name])
            end
        end
        
        function val = get.dataType(obj)
            %getter for property dataType
            if(~isempty(obj.dataType))
                val = obj.dataType;
            else
                val = obj.dataType;
            end
        end
        
        function set.initValue(obj,string)
            %setter for property initValue
            if(~isempty(string))
                obj.initValue = string;
            else
                disp(['Warning: trying to assign empty string to propery "initValue" of object: ',obj.name])
            end
        end
        
        function val = get.initValue(obj)
            %getter for property initValue
            if(~isempty(obj.initValue))
                val = obj.initValue;
            else
                val = obj.initValue;
            end
        end
        

        function set.comSpec(obj,string)
            %setter for property comSpec
            if(~isempty(string))
                obj.comSpec = string;
            else
                disp(['Warning: trying to assign empty string to propery "comSpec" of object: ',obj.name])
            end
        end
        
        function val = get.comSpec(obj)
            %getter for property typeEmitter
            if(~isempty(obj.comSpec))
                val = obj.comSpec;
            else
                val = obj.comSpec;
            end
        end
        
       %%  validate block
        function err = validate(obj)
           %checks that all the poperties of the class are correct
            
            %disp(['Validating: ',obj.name])
            err = 0;
            
            %check that package is assigned
            if(isempty(obj.package))
                 disp(['Warning: ',obj.package,' does not have a package defined']);
                err = 1;
            end
            
            %check that name is assigned
            if(isempty(obj.name))
                 disp(['Warning: ',obj.name,' does not have a name defined']);
                err = 1;
            end
            
            %check that package is correct
            %-not needed

            %check that calAccess is defined
            if(isempty(obj.calAccess))
                disp(['Warning: ',obj.name,' does not have a calAccess defined']);
                err = 1;
            else
                if(~strcmp(obj.calAccess,'READ-ONLY'))
                    disp(['Warning: ',obj.name,' does not have calAccess set to READ-ONLY']); 
                end
            end
            
            %check that SWImpPolicy is defined
            if(isempty(obj.SWImpPolicy))
                disp(['Warning: ',obj.name,' does not have a SWImpPolicy defined']);
                err = 1;
            else
                if(~strcmp(obj.SWImpPolicy,'STANDARD'))
                    disp(['Warning: ',obj.name,' does not have SWImpPolicy set to STANDARD']); 
                end
            end
            
                                    
            %% validate children
            %check that dataType set is defined
            if(isempty(obj.dataType))
                disp(['Warning: ',obj.name,' does not have a dataType defined']);
                err = 1;
            else
                %validate com spec
                obj.dataType.validate;
            end
            
            %check that init value set is defined
            if(isempty(obj.initValue))
                disp(['Warning: ',obj.name,' does not have a initValue defined']);
                err = 1;
            else
                %validate com spec
                obj.initValue.validate;
            end
            


        end
        
    end
end

