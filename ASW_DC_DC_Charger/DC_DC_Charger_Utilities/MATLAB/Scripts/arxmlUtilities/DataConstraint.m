classdef DataConstraint < handle

    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        physConstUpLim
        physConstLowLim
    end
    
    methods
        %% construtor 
        function obj = DataConstraint(package,name)
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
        
         function set.physConstUpLim(obj,string)
            %setter for property physConstUpLim
            if(~isempty(string))
                obj.physConstUpLim = string;
            else
                disp(['Warning: trying to assign empty string to propery "physConstUpLim" of object: ',obj.name])
            end
        end
        
        function val = get.physConstUpLim(obj)
            %getter for property physConstUpLim
            if(~isempty(obj.physConstUpLim))
                val = obj.physConstUpLim;
            else
                val = obj.physConstUpLim;
            end
        end
        
       function set.physConstLowLim(obj,string)
            %setter for property physConstLowLim
            if(~isempty(string))
                obj.physConstLowLim = string;
            else
                disp(['Warning: trying to assign empty string to propery "physConstLowLim" of object: ',obj.name])
            end
        end
        
        function val = get.physConstLowLim(obj)
            %getter for property physConstLowLim
            if(~isempty(obj.physConstLowLim))
                val = obj.physConstLowLim;
            else
                val = obj.physConstLowLim;
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
            
            %this has been moved to one level higher
%             %check that physConstUpLim exists 
%             if(isempty(obj.physConstUpLim))
%                 disp(['Warning: ',obj.name,' does not have a physConstUpLim defined']);
%                 err = 1;
%             end
%             
%             %check that physConstLowLim exists  
%             if(isempty(obj.physConstLowLim))
%                 disp(['Warning: ',obj.name,' does not have a physConstLowLim defined']);
%                 err = 1;
%             end
            
            %TODO: add a check for internal limit definition
            
        end
    end
end

