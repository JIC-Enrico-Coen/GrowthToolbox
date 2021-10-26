classdef XMLstack < handle
    properties
        stack
        fid
    end
    
    methods (Static)
        function x = new( file )
            x = XMLstack();
            if ischar(file)
                x.fid = fopen( file, 'w' );
            else
                x.fid = file;
            end
            if x.fid ~= -1
                fprintf( x.fid, '<?xml version="1.0" encoding="utf-8"?>\n' );
            end
        end
    end
    
    methods
        function is = isopen( x )
            is = x.fid ~= -1;
        end
        
        function push( x, v )
            x.stack{end+1} = v;
        end
        
        function v = pop( x )
            if isempty(x.stack)
                v = [];
            else
                v = x.stack{end};
                x.stack = x.stack(1:(end-1));
            end
        end
        
        function popto( x, s )
            while ~isempty(x.stack) && ~strcmp( x.stack{end}, s )
                endxmlelement( x );
            end
            if ~isempty(x.stack)
                endxmlelement( x );
            end
        end
        
        function n = len( x )
            n = length(x.stack);
        end
        
        function close( x )
            if x.fid ~= -1
                fclose( x.fid );
                x.fid = -1;
            end
        end
    end
end
