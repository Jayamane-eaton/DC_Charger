classdef ImpDataType < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        category
        baseType
        typeEmitter
        impTypeRef
    end
    
    methods
        %% construtor 
        function obj = ImpDataType(package,name)
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
        
         function set.category(obj,string)
            %setter for property category
            if(~isempty(string))
                obj.category = string;
            else
                disp(['Warning: trying to assign empty string to propery "category" of object: ',obj.name])
            end
        end
        
        function val = get.category(obj)
            %getter for property category
            if(~isempty(obj.category))
                val = obj.category;
            else
                val = obj.category;
            end
        end

       function set.baseType(obj,string)
            %setter for property baseType
            if(~isempty(string))
                obj.baseType = string;
            else
                disp(['Warning: trying to assign empty string to propery "baseType" of object: ',obj.name])
            end
        end
        
        function val = get.baseType(obj)
            %getter for property typeEmitter
            if(~isempty(obj.baseType))
                val = obj.baseType;
            else
                val = obj.baseType;
            end
        end
        
        function set.typeEmitter(obj,string)
            %setter for property typeEmitter
            if(~isempty(string))
                obj.typeEmitter = string;
            else
                %disp(['Warning: trying to assign empty string to propery "typeEmitter" of object: ',obj.name])
            end
        end
        
        function val = get.typeEmitter(obj)
            %getter for property typeEmitter
            if(~isempty(obj.typeEmitter))
                val = obj.typeEmitter;
            else
                val = obj.typeEmitter;
            end
        end
        
        function set.impTypeRef(obj,string)
            %setter for property impTypeRef
            if(~isempty(string))
                obj.impTypeRef = string;
            else
                disp(['Warning: trying to assign empty string to propery "impTypeRef" of object: ',obj.name])
            end
        end
        
        function val = get.impTypeRef(obj)
            %getter for property impTypeRef
            if(~isempty(obj.impTypeRef))
                val = obj.impTypeRef;
            else
                val = obj.impTypeRef;
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
            if(~strcmp(obj.package,'/Interfaces/DataTypes/ImplementationDataTypes/'))
                disp(['Warning: ',obj.name,' is located in the wrong package: ',obj.package]);
                err = 1;
            end
            
            %check that catagory exists and that corresponding properties are defined 
            if(isempty(obj.category))
                disp(['Warning: ',obj.name,' does not have a catagory defined']);
                err = 1;
            end
            
            %check that impTypeRef is defined
            if(~isempty(obj.impTypeRef))
                %disp(['Warning: ',obj.name,' has reference to implmentation data type: ',obj.impTypeRef,' this data type should reference a base type instead']);
                %TODO: should corret this so that it creates a new datatype and checks the basetype
                err = 1;
                
            else
                %check that typeEmitter is defined
                if(isempty(obj.typeEmitter))
                    disp(['Warning: ',obj.name,' does not have a typeEmitter defined']);
                    err = 1;
                end
                
                %% validate children
                %check that baseType set is defined
                if(isempty(obj.baseType))
                    disp(['Warning: ',obj.name,' does not have a baseType defined']);
                    err = 1;
                else
                    %validate data constraint
                    obj.baseType.validate;
                end
                
            end
            

                        


        end
        
    end
end

