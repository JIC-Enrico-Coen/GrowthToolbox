function [ok,s] = checkcommandargs( commandname, s, mode, varargin )
%ok = checkcommandargs( commandname, s, mode, varargin )
%   varargin is a series of string arguments or a cell array of strings.
%   s is a struct.
%   If mode is 'incl', determine whether the fields of s include all the
%   members of varargin.
%   If mode is 'only', determine whether the fields of s are contained in
%   varargin.
%   If mode is 'exact', determine whether the fields of s are precisely the
%   members of varargin.
%   For modes 'only' and 'exact', if s is found to have extra fields then
%   these fields will be deleted from s.
    
    ok = true;
    if ~isempty(varargin) && iscell( varargin{1} )
        varargin = varargin{1};
    end
    u = checkstructfields( s, mode, varargin{:} );
    if ~isempty(u)
        if isfield( u, 'extra' ) && ~isempty( u.extra )
            fprintf( 1, 'Unrecognised arguments supplied to command "%s":\n', ...
                commandname );
            for i=1:length(u.extra)
                fprintf( 1, '     %s\n', u.extra{i} );
            end
            fprintf( 1, 'Ignored.\n' );
            s = rmfield( s, u.extra );
        end
        if isfield( u, 'missing' ) && ~isempty( u.missing )
            fprintf( 1, 'Missing arguments for command "%s":\n', ...
                commandname );
            for i=1:length(u.missing)
                fprintf( 1, '     %s\n', u.missing{i} );
            end
            fprintf( 1, 'Command ignored.\n' );
            ok = false;
        end
    end
end
