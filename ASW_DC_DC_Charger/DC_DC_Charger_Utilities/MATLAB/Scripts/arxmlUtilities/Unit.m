classdef Unit < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        displayName
        factorToSI
        offsetToSI
        physicalDimensionRef
        
    end
    
    methods
        %% construtor 
        function obj = Unit(package,name)
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
        
         function set.displayName(obj,string)
            %setter for property displayName
            if(~isempty(string))
                obj.displayName = string;
            else
                disp(['Warning: trying to assign empty string to propery "displayName" of object: ',obj.name])
            end
        end
        
        function val = get.displayName(obj)
            %getter for property displayName
            if(~isempty(obj.displayName))
                val = obj.displayName;
            else
                val = obj.displayName;
            end
        end
        
       function set.factorToSI(obj,string)
            %setter for property factorToSI
            if(~isempty(string))
                obj.factorToSI = string;
            else
                disp(['Warning: trying to assign empty string to propery "factorToSI" of object: ',obj.name])
            end
        end
        
        function val = get.factorToSI(obj)
            %getter for property factorToSI
            if(~isempty(obj.factorToSI))
                val = obj.factorToSI;
            else
                val = obj.factorToSI;
            end
        end
        
        function set.offsetToSI(obj,string)
            %setter for property offsetToSI
            if(~isempty(string))
                obj.offsetToSI = string;
            else
                %disp(['Warning: trying to assign empty string to propery "offsetToSI" of object: ',obj.name])
            end
        end
 
        function val = get.offsetToSI(obj)
            %getter for property offsetToSI
            if(~isempty(obj.offsetToSI))
                val = obj.offsetToSI;
            else
                val = obj.offsetToSI;
            end
        end
        
        function set.physicalDimensionRef(obj,string)
            %setter for property physicalDimensionRef
            if(~isempty(string))
                obj.physicalDimensionRef = string;
            else
                disp(['Warning: trying to assign empty string to propery "physicalDimensionRef" of object: ',obj.name])
            end
        end
 
        function val = get.physicalDimensionRef(obj)
            %getter for property physicalDimensionRef
            if(~isempty(obj.physicalDimensionRef))
                val = obj.physicalDimensionRef;
            else
                val = obj.physicalDimensionRef;
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
            if(~strcmp(obj.package,'/Units_Package/'))
                disp(['Warning: ',obj.name,' is located in the wrong package: ',obj.package]);
                err = 1;
            end
            
            %check that factor is assigned 
            if(isempty(obj.factorToSI))
                 disp(['Warning: ',obj.name,' does not have a factor to SI unit defined']);
                err = 1;
            end
            
            %check that offset is assigned - not always needed
            if(isempty(obj.offsetToSI))
                %disp(['Warning: ',obj.name,' does not have a offset to SI unit defined']);
                err = 1;
            end
            
            %check that offset is assigned
            if(isempty(obj.physicalDimensionRef))
                disp(['Warning: ',obj.name,' does not have a reference to a physical dimension defined']);
                err = 1;
            end
        end
    end
end

