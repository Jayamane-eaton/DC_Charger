classdef Port < handle
    %Unit this contains all the properties of an AUTOSAR unit
    properties
        package
        name
        type
        interface
    end
    
    methods
        %% construtor 
        function obj = Port(package,name)
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
        
        function set.type(obj,string)
            %setter for property type
            if(~isempty(string))
                obj.type = string;
            else
                disp(['Warning: trying to assign empty string to propery "type" of object: ',obj.type])
            end
        end
        
        function val = get.type(obj)
            %getter
            if(~isempty(obj.type))
                val = obj.type;
            else
                val = obj.type;
            end
        end
        
         function set.interface(obj,string)
            %setter for property interface
            if(~isempty(string))
                obj.interface = string;
            else
                disp(['Warning: trying to assign empty string to propery "interface" of object: ',obj.name])
            end
        end
        
        function val = get.interface(obj)
            %getter for property interface
            if(~isempty(obj.interface))
                val = obj.interface;
            else
                val = obj.interface;
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
            %-not needed

            
            if(isempty(obj.type))
                disp(['Warning: ',obj.name,' does not have port type defined']);
                err = 1;
            else
                if(strcmp(obj.type,'R'))
                    %verify name of ports
                    if(~startsWith(obj.name,'R_'))
                        disp(['Warning: ',obj.name,' has a R port with an incorrect name: ',obj.ports.name]);
                    end
                elseif(strcmp(obj.type,'P'))
                    %verify name of ports
                    if(~startsWith(obj.name,'P_'))
                        disp(['Warning: ',obj.name,' has a P port with an incorrect name: ',obj.ports.name]);
                    end
                end
            end
            
                                    
            %% validate children
            %check that interface is defined
            if(isempty(obj.interface))
                disp(['Warning: ',obj.name,' does not have a interface defined']);
                err = 1;
            else
                %validate com spec
                obj.interface.validate;
            end
            

            %validate com spec only if it is a P port
            if(~isempty(obj.interface.dataElements) && strcmp(obj.type,'P'))
                
                for(jj = 1:length(obj.interface.dataElements))
                    %check that comSpec set is defined
                    if(isempty(obj.interface.dataElements{jj}.comSpec))
                        disp(['Warning: ',obj.interface.dataElements{jj}.name,' does not have a comSpec defined and it is a P-Port']);
                        err = 1;
                    else
                        %validate com spec
                        obj.interface.dataElements{jj}.comSpec.validate;
                    end
                end
                
            end

        end
        
    end
end

