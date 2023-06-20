classdef SoftwareComponent < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        SWImp
        internalBehavior
        ports
    end
    
    methods
        %% construtor
        function obj = SoftwareComponent(package,name)
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
        
        function set.SWImp(obj,string)
            %setter for property SWImp
            if(~isempty(string))
                obj.SWImp = string;
            else
                disp(['Warning: trying to assign empty string to propery "SWImp" of object: ',obj.name])
            end
        end
        
        function val = get.SWImp(obj)
            %getter for property SWImp
            if(~isempty(obj.SWImp))
                val = obj.SWImp;
            else
                val = obj.SWImp;
            end
        end
        
        function set.internalBehavior(obj,string)
            %setter for property internalBehavior
            if(~isempty(string))
                obj.internalBehavior = string;
            else
                disp(['Warning: trying to assign empty string to propery "internalBehavior" of object: ',obj.name])
            end
        end
        
        function val = get.internalBehavior(obj)
            %getter for property internalBehavior
            if(~isempty(obj.internalBehavior))
                val = obj.internalBehavior;
            else
                val = obj.internalBehavior;
            end
        end
        
        function set.ports(obj,string)
            %setter for property ports
            if(~isempty(string))
                obj.ports = string;
            else
                disp(['Warning: trying to assign empty string to propery "ports" of object: ',obj.name])
            end
        end
        
        function val = get.ports(obj)
            %getter for property ports
            if(~isempty(obj.ports))
                val = obj.ports;
            else
                val = obj.ports;
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
            
            %check that description exists
            if(isempty(obj.SWImp))
                disp(['Warning: ',obj.name,' does not have a SWImp defined']);
                err = 1;
            end
            
            %% validate children
            
            %check that data type mapping set is defined
            if(isempty(obj.internalBehavior))
                disp(['Warning: ',obj.name,' does not have a internalBehavior defined']);
                err = 1;
            else
                %validate data constraint
                obj.internalBehavior.validate;
            end
            
            %check that ports is defined
            if(isempty(obj.ports))
                disp(['Warning: ',obj.name,' does not have a ports defined']);
                err = 1;
            else
                %validate data constraint
                for(ii=1:length(obj.ports))
                    obj.ports{ii}.validate;
                end
                
            end
        end
    end
end

