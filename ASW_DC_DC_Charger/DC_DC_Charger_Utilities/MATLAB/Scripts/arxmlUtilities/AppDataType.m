classdef AppDataType < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        category
        description
        compuMethod
        dataConstraint
        dataTypeMappingSet
        impDataType
        
    end
    
    methods
        %% construtor 
        function obj = AppDataType(package,name)
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
        
       function set.compuMethod(obj,string)
            %setter for property compuMethod
            if(~isempty(string))
                obj.compuMethod = string;
            else
                disp(['Warning: trying to assign empty string to propery "compuMethod" of object: ',obj.name])
            end
        end
        
        function val = get.compuMethod(obj)
            %getter for property compuMethod
            if(~isempty(obj.compuMethod))
                val = obj.compuMethod;
            else
                val = obj.compuMethod;
            end
        end
        
        function set.dataConstraint(obj,string)
            %setter for property dataConstraint
            if(~isempty(string))
                obj.dataConstraint = string;
            else
                disp(['Warning: trying to assign empty string to propery "dataConstraint" of object: ',obj.name])
            end
        end
        
        function val = get.dataConstraint(obj)
            %getter for property dataConstraint
            if(~isempty(obj.dataConstraint))
                val = obj.dataConstraint;
            else
                val = obj.dataConstraint;
            end
        end
        
       function set.dataTypeMappingSet(obj,string)
            %setter for property dataTypeMappingSet
            if(~isempty(string))
                obj.dataTypeMappingSet = string;
            else
                disp(['Warning: trying to assign empty string to propery "dataTypeMappingSet" of object: ',obj.name])
            end
        end
        
        function val = get.dataTypeMappingSet(obj)
            %getter for property dataTypeMappingSet
            if(~isempty(obj.dataTypeMappingSet))
                val = obj.dataTypeMappingSet;
            else
                val = obj.dataTypeMappingSet;
            end
        end
        
        function set.impDataType(obj,string)
            %setter for property impDataType
            if(~isempty(string))
                obj.impDataType = string;
            else
                disp(['Warning: trying to assign empty string to propery "impDataType" of object: ',obj.name])
            end
        end
        
        function val = get.impDataType(obj)
            %getter for property dataTypeMappingSet
            if(~isempty(obj.impDataType))
                val = obj.impDataType;
            else
                val = obj.impDataType;
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
            if(~strcmp(obj.package,'/Interfaces/DataTypes/ApplicationDataTypes/'))
                disp(['Warning: ',obj.name,' is located in the wrong package: ',obj.package]);
                err = 1;
            end
            
            %check that catagory exists and that corresponding properties are defined 
            if(isempty(obj.category))
                disp(['Warning: ',obj.name,' does not have a catagory defined']);
                err = 1;
            end
            
            %check that description exists  
            if(isempty(obj.description))
                disp(['Warning: ',obj.name,' does not have a description']);
                err = 1;
            end
            
            %% validate children 
            
            %check that compuMethod is defined
            if(isempty(obj.compuMethod))
                disp(['Warning: ',obj.name,' does not have a compuMethod defined']);
                err = 1;
            else
                %validate data constraint
                obj.compuMethod.validate;
                
                %verify name of compu method
                if(~strcmp(strrep(obj.name,'APDT_',''),strrep(obj.compuMethod.name,'CM_','')))
                    disp(['Warning: ',obj.name,' has a compu method with an incorrect name: ',obj.compuMethod.name]);
                end
                
            end
            
            %check that data constraint is defined
            if(isempty(obj.dataConstraint))
                disp(['Warning: ',obj.name,' does not have a dataConstraint defined']);
                err = 1;
            else
                %validate data constraint
                obj.dataConstraint.validate;
                
                %validate data constraint based on compuMethod
                if(strcmp(obj.compuMethod.category,'IDENTICAL') || strcmp(obj.compuMethod.category,'LINEAR'))
                
                    %check that physConstUpLim exists
                    if(isempty(obj.dataConstraint.physConstUpLim))
                        disp(['Warning: ',obj.name,' does not have a physConstUpLim defined']);
                        err = 1;
                    end
                    
                    %check that physConstLowLim exists
                    if(isempty(obj.dataConstraint.physConstLowLim))
                        disp(['Warning: ',obj.name,' does not have a physConstLowLim defined']);
                        err = 1;
                    end
                
                end
                
                %TODO: add data constraint cehck for internal type
                
                
                %verify name of compu method
                if(~strcmp(obj.name,strrep(obj.dataConstraint.name,'_DC','')))
                    disp(['Warning: ',obj.name,' has a data contraint with an incorrect name: ',obj.dataConstraint.name]);
                end
                
            end
            
            %check that data type mapping set is defined
            if(isempty(obj.dataTypeMappingSet))
                disp(['Warning: ',obj.name,' does not have a dataTypeMappingSet defined']);
                err = 1;
            else
                %validate data constraint
                obj.dataTypeMappingSet.validate;
                
                %verify name of compu method
                if(~strcmp(obj.name,strrep(obj.dataTypeMappingSet.name,'DTMS_','')))
                    disp(['Warning: ',obj.name,' has a data data type mapping set with an incorrect name: ',obj.dataTypeMappingSet.name]);
                end
                
            end
            
            %check that impDataType set is defined
            if(isempty(obj.impDataType))
                disp(['Warning: ',obj.name,' does not have a impDataType defined']);
                err = 1;
            else
                %validate data constraint
                obj.impDataType.validate;
                
                %verify name of compu method
                if(~strcmp(strrep(obj.name,'APDT_',''),strrep(obj.impDataType.name,'DT_','')))
                    disp(['Warning: ',obj.name,' has a implementation data type with an incorrect name: ',obj.impDataType.name]);
                end
                
            end
            
               
        end
    end
end
