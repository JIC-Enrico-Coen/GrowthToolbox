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
    if isempty(m) || isempty( varargin )
        return;
    end
    
    ifhandle = m.globalProps.mgen_interaction;
    if isempty( ifhandle )
        return;
    end
    
    ifname = func2str( ifhandle );
    fn = ['GFtbox_', varargin{1}, '_Callback' ];
    if ~isa( ifhandle, 'function_handle' )
        timedFprintf( 'Interaction function %s not found for callback %s.\n', ifname, fn );
        return;
    end
    
%     gotif = false;
%     
%     if isempty( which(ifname) )
%         % Try to find the directory of the project and make a
%         % handle to the interaction function there.
%         modelpathname = fullfile( m.globalProps.projectdir, m.globalProps.modelname );
%         if exist( fullfile( modelpathname, [ ifname, '.m' ] ), 'file' )
%             olddir = cd( modelpathname );
%             try
%                 ifhandle = eval( [ '@', ifname ] );
%                 iffunctions = functions( ifhandle );
%                 if ~isempty( iffunctions ) && ~isempty( iffunctions.file )
%                     gotif = true;
%                 end
%             catch e
%             end
%             cd( olddir );
%         end
%         timedFprintf( 'Interaction function %s not found for callback %s.\n', ifname, fn );
%     else
%                 try
            [m,results] = m.globalProps.mgen_interaction( m, fn, varargin{2:end} );
%                 catch e
%                     if strcmp( e.identifier, 'MATLAB:UndefinedFunction' )
%                         timedFprintf( 'Interaction function %s not found for callback %s:\n%s\n', ifname, fn, e.message );
%                     else
%                         timedFprintf( 'Error raised in interaction function %s for callback %s:\n%s %s\n', ifname, fn, e.identifier, e.message );
%                         rethrow(e);
%                     end
%                     results = [];
%                 end
%     end
end
