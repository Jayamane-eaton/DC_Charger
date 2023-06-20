classdef CompuMethod < handle
    %unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        category
        LSB
        offset
        unit
        
    end
    
    methods
        %% construtor 
        function obj = CompuMethod(package,name)
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
        
       function set.LSB(obj,string)
            %setter for property LSB
            if(~isempty(string))
                obj.LSB = string;
            else
                %disp(['Warning: trying to assign empty string to propery "LSB" of object: ',obj.name])
            end
        end
        
        function val = get.LSB(obj)
            %getter for property LSB
            if(~isempty(obj.LSB))
                val = obj.LSB;
            else
                val = obj.LSB;
            end
        end
        
        function set.offset(obj,string)
            %setter for property offset
            if(~isempty(string))
                obj.offset = string;
            else
                %disp(['Warning: trying to assign empty string to propery "offset" of object: ',obj.name])
            end
        end
 
        function val = get.offset(obj)
            %getter for property offset
            if(~isempty(obj.offset))
                val = obj.offset;
            else
                val = obj.offset;
            end
        end
        
        function set.unit(obj,string)
            %setter for property unit
            if(~isempty(string))
                obj.unit = string;
            else
                disp(['Warning: trying to assign empty string to propery "unit" of object: ',obj.name])
            end
        end
 
        function val = get.unit(obj)
            %getter for property unit
            if(~isempty(obj.unit))
                val = obj.unit;
            else
                val = obj.unit;
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
            if(~strcmp(obj.package,'/Interfaces/CompuMethods/'))
                disp(['Warning: ',obj.name,' is located in the wrong package: ',obj.package]);
                err = 1;
            end
            
            %check that catagory exists and that corresponding properties are defined 
            if(isempty(obj.category))
                disp(['Warning: ',obj.name,' does not have a catagory defined']);
                err = 1;
            else
                
                %based on type check factor and offset
                if(strcmp(obj.category,'IDENTICAL'))
                    %do nothing no addtional properties need to be checked
                elseif(strcmp(obj.category,'LINEAR'))
                    %check that factor is assigned
                    if(isempty(obj.LSB))
                        disp(['Warning: ',obj.name,' does not have a LSB']);
                        err = 1;
                    end
                    
                    %check that offset is assigned
                    if(isempty(obj.offset))
                        disp(['Warning: ',obj.name,' does not have a offset defined']);
                        err = 1;
                    end
                    
                elseif(strcmp(obj.category,'TEXTTABLE'))
                    %TODO: need to figure out how to handle textable catagory
                else
                    disp(['Warning: ',obj.name,' has unsuported catagory: ',obj.category]);
                end
                
            end
            
            %% validate children
            
            %check that offset is assigned
            if(isempty(obj.unit))
                disp(['Warning: ',obj.name,' does not have a unit defined']);
                err = 1;
            else
                %validate the unit
                err = obj.unit.validate;    
            end
            
            
        end
    end
end
