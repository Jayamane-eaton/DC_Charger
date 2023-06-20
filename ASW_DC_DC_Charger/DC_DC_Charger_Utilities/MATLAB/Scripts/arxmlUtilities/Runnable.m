classdef Runnable < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        minStartInterval
        canBeInvokedConcurrently
        portReadAccess
        portWriteAccess
    end
    
    methods
        %% construtor
        function obj = Runnable(package,name)
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
        
        function set.minStartInterval(obj,string)
            %setter for property minStartInterval
            if(~isempty(string))
                obj.minStartInterval = string;
            else
                disp(['Warning: trying to assign empty string to propery "minStartInterval" of object: ',obj.name])
            end
        end
        
        function val = get.minStartInterval(obj)
            %getter for property minStartInterval
            if(~isempty(obj.minStartInterval))
                val = obj.minStartInterval;
            else
                val = obj.minStartInterval;
            end
        end
        
        function set.canBeInvokedConcurrently(obj,string)
            %setter for property canBeInvokedConcurrently
            if(~isempty(string))
                obj.canBeInvokedConcurrently = string;
            else
                disp(['Warning: trying to assign empty string to propery "canBeInvokedConcurrently" of object: ',obj.name])
            end
        end
        
        function val = get.canBeInvokedConcurrently(obj)
            %getter for property canBeInvokedConcurrently
            if(~isempty(obj.canBeInvokedConcurrently))
                val = obj.canBeInvokedConcurrently;
            else
                val = obj.canBeInvokedConcurrently;
            end
        end
        
        function set.portReadAccess(obj,string)
            %setter for property portReadAccess
            if(~isempty(string))
                obj.portReadAccess = string;
            else
                disp(['Warning: trying to assign empty string to propery "portReadAccess" of object: ',obj.name])
            end
        end
        
        function val = get.portReadAccess(obj)
            %getter for property portsReadAccess
            if(~isempty(obj.portReadAccess))
                val = obj.portReadAccess;
            else
                val = obj.portReadAccess;
            end
        end
        
        function set.portWriteAccess(obj,string)
            %setter for property portReadAccess
            if(~isempty(string))
                obj.portWriteAccess = string;
            else
                disp(['Warning: trying to assign empty string to propery "portWriteAccess" of object: ',obj.name])
            end
        end
        
        function val = get.portWriteAccess(obj)
            %getter for property portsReadAccess
            if(~isempty(obj.portWriteAccess))
                val = obj.portWriteAccess;
            else
                val = obj.portWriteAccess;
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
            
            %check that minStartInterval exists
            if(isempty(obj.minStartInterval))
                disp(['Warning: ',obj.name,' does not have a minStartInterval defined']);
                err = 1;
            else
                if(~strcmp(obj.minStartInterval,'0'))
                    disp(['Warning: ',obj.name,' min start interval is set to something other than 0 -> ',obj.minStartInterval]);
                    err = 1;
                end
            end
            
            %check that minStartInterval exists
            if(isempty(obj.canBeInvokedConcurrently))
                disp(['Warning: ',obj.name,' does not have a canBeInvokedConcurrently defined']);
                err = 1;
            else
                if(~strcmp(obj.canBeInvokedConcurrently,'false'))
                    disp(['Warning: ',obj.name,' canBeInvokedConcurrently is set to ',obj.minStartInterval]);
                    err = 1;
                end
            end
            
            %% validate children
            %check that portReadAccess is defined
            if(isempty(obj.portReadAccess))
                disp(['Warning: ',obj.name,' does not have a portReadAccess defined']);
                err = 1;
            end
            
            %check that portWriteAccess is defined
            if(isempty(obj.portWriteAccess))
                disp(['Warning: ',obj.name,' does not have a portWriteAccess defined']);
                err = 1;
            end
            
        end
    end
end

