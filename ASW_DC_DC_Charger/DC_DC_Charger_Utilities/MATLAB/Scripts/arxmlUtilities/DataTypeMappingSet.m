classdef DataTypeMappingSet < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        appDataTypeRef
        impDataTypeRef
    end
    
    methods
        %% construtor 
        function obj = DataTypeMappingSet(package,name)
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
        
         function set.appDataTypeRef(obj,string)
            %setter for property appDataTypeRef
            if(~isempty(string))
                obj.appDataTypeRef = string;
            else
                disp(['Warning: trying to assign empty string to propery "appDataTypeRef" of object: ',obj.name])
            end
        end
        
        function val = get.appDataTypeRef(obj)
            %getter for property appDataTypeRef
            if(~isempty(obj.appDataTypeRef))
                val = obj.appDataTypeRef;
            else
                val = obj.appDataTypeRef;
            end
        end
        
        function set.impDataTypeRef(obj,string)
            %setter for property impDataTypeRef
            if(~isempty(string))
                obj.impDataTypeRef = string;
            else
                disp(['Warning: trying to assign empty string to propery "impDataTypeRef" of object: ',obj.name])
            end
        end
        
        function val = get.impDataTypeRef(obj)
            %getter for property appDataTypeRef
            if(~isempty(obj.impDataTypeRef))
                val = obj.impDataTypeRef;
            else
                val = obj.impDataTypeRef;
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
            if(~strcmp(obj.package,'/Interfaces/DataTypes/DataTypeMappingSets/'))
                disp(['Warning: ',obj.name,' is located in the wrong package: ',obj.package]);
                err = 1;
            end
                        
            %check that appDataTypeRef exists 
            if(isempty(obj.appDataTypeRef))
                disp(['Warning: ',obj.name,' does not have a appDataTypeRef defined']);
                err = 1;
            end
            
            %check that impDataTypeRef exists  
            if(isempty(obj.impDataTypeRef))
                disp(['Warning: ',obj.name,' does not have a impDataTypeRef defined']);
                err = 1;
            end
              
        end
    end
end
