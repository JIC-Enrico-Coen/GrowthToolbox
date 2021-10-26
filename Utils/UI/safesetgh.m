function safesetgh( handles, field, varargin )
%safesetgh( handles, field, varargin )
%   Like set( handles.field, varargin{:} ), except that it tests that the
%   field exists and it nonempty.

    if isfield( handles, field ) && ~isempty( handles.(field) )
        set( handles.(field), varargin{:} );
    end
end
