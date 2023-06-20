classdef DataConstant < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        category
        valuePhys
        unit

    end
    
    methods
        %% construtor 
        function obj = DataConstant(package,name)
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

       function set.valuePhys(obj,string)
            %setter for property valuePhys
            if(~isempty(string))
                obj.valuePhys = string;
            else
                disp(['Warning: trying to assign empty string to propery "valuePhys" of object: ',obj.name])
            end
        end
        
        function val = get.valuePhys(obj)
            %getter for property valuePhys
            if(~isempty(obj.valuePhys))
                val = obj.valuePhys;
            else
                val = obj.valuePhys;
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
            if(~strcmp(obj.package,'/Interfaces/SenderReceiverInitValues/'))
                disp(['Warning: ',obj.name,' is located in the wrong package: ',obj.package]);
                err = 1;
            end
            
            %check that category exists and that corresponding properties are defined 
            if(isempty(obj.category))
                disp(['Warning: ',obj.name,' does not have a category defined']);
                err = 1;
            end
            
            %% validate children
            
            %check that offset is assigned
            if(isempty(obj.unit))
                %disp(['Warning: ',obj.name,' does not have a unit defined']);
                %TODO: not sure why some of these constants have a unit to them
                err = 1;
            else
                %validate the unit
                err = obj.unit.validate;    
            end
        end    
    end
end

