classdef BaseType < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        baseTypeSize
        serviceKind

    end
    
    methods
        %% construtor 
        function obj = BaseType(package,name)
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
        
         function set.baseTypeSize(obj,string)
            %setter for property baseTypeSize
            if(~isempty(string))
                obj.baseTypeSize = string;
            else
                disp(['Warning: trying to assign empty string to propery "baseTypeSize" of object: ',obj.name])
            end
        end
        
        function val = get.baseTypeSize(obj)
            %getter for property baseTypeSize
            if(~isempty(obj.baseTypeSize))
                val = obj.baseTypeSize;
            else
                val = obj.baseTypeSize;
            end
        end

       function set.serviceKind(obj,string)
            %setter for property serviceKind
            if(~isempty(string))
                obj.serviceKind = string;
            else
                disp(['Warning: trying to assign empty string to propery "serviceKind" of object: ',obj.name])
            end
        end
        
        function val = get.serviceKind(obj)
            %getter for property typeEmitter
            if(~isempty(obj.serviceKind))
                val = obj.serviceKind;
            else
                val = obj.serviceKind;
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
            if(~strcmp(obj.package,'/AUTOSAR/Platform/BaseTypes/'))
                disp(['Warning: ',obj.name,' is located in the wrong package: ',obj.package]);
                err = 1;
            end
            
            %check that baseTypeSize exists and that corresponding properties are defined 
            if(isempty(obj.baseTypeSize))
                disp(['Warning: ',obj.name,' does not have a baseTypeSize defined']);
                err = 1;
            end
            
            %check that typeEmitter is defined
            if(isempty(obj.serviceKind))
                disp(['Warning: ',obj.name,' does not have a serviceKind defined']);
                err = 1;
            end
        end    
    end
end

