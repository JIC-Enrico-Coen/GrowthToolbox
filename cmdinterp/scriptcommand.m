function m = scriptcommand( m, commandname, varargin )
%m = scriptcommand( m, commandname, varargin )
%   Execute the command with the given name.  The arguments are varargin.

    m = feval( [ 'leaf_' commandname ], m, varargin{:} );
end

