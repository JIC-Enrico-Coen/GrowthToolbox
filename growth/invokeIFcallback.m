function [m,results] = invokeIFcallback( m, varargin )
%[m,results] = invokeIFcallback( m, callback, varargin )
%   Invoke the function called ['GFtbox_', callback, '_Callback' ], that
%   should be defined in the interaction function.
%   The function should return two results: the first is the mesh itself,
%   and the second is whatever result it needs to return (using e.g. a
%   struct to return multiple results).

    results = [];
    if ischar( m )
        varargin = [ m, varargin ];
        m = getGFtboxMesh();
    end
    if ~isempty(m) && ~isempty( varargin )
        if isa(m.globalProps.mgen_interaction,'function_handle')
            ifname = func2str(m.globalProps.mgen_interaction);
            fn = ['GFtbox_', varargin{1}, '_Callback' ];
            if isempty( which(ifname) )
                timedFprintf( 'Interaction function %s not found for callback %s.\n', ifname, fn );
            else
                try
                    [m,results] = m.globalProps.mgen_interaction( m, fn, varargin{2:end} );
                catch e
                    if strcmp( e.identifier, 'MATLAB:UndefinedFunction' )
                        timedFprintf( 'Interaction function %s not found for callback %s:\n%s\n', ifname, fn, e.message );
                    else
                        timedFprintf( 'Error raised in interaction function %s for callback %s:\n%s %s\n', ifname, fn, e.identifier, e.message );
                        rethrow(e);
                    end
                    results = [];
                end
            end
        else
            results = [];
        end
    end
end
