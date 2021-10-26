function [done,h] = meshSetProperty( h, varargin )
    if ~isempty(h.mesh)
        [done,h] = attemptCommand( h, false, false, ...
            'setproperty', varargin{:} );
    end

