function [s,ok] = safemakestruct( self, varargin )
%s = safemakestruct( self, args )
%   Construct a struct S from the cell array ARGS by S = STRUCT(ARGS), but
%   catch and report errors.  ARGS is expected to be the VARARGIN argument
%   of the function this is called from.  ARGS may also be a structure, in
%   which case S is set to ARGS and OK to true.  If ARGS is absent, S is
%   set to the empty structure and OK to true.
%
%   Unlike STRUCT, SAFEMAKESTRUCT does not treat cell array arguments
%   specially.
%
%   The SELF argument is a string used in error messages, and should
%   typically be the name of the procedure this function was called from
%   (e.g. as provided by MFILENAME()).  If SELF is empty, no error messages
%   will be printed.

    s = struct();
    ok = true;
    if nargin==1
        return;
    end
    if isempty(varargin)
        return;
    end
    if length(varargin) > 1
        args = varargin;
    else
        args = varargin{1};
    end
    
    if iscell(args) && (length(args)==1) && isstruct(args{1})
        s = args{1};
        return;
    end
    if isstruct(args)
        s = args;
        return;
    end
    n = length(args);
    if mod(n,2) ~= 0
        ok = false;
    else
        try
            for i=1:2:n-1
                s.(despace(args{i})) = args{i+1};
            end
        catch e %#ok<NASGU>
            ok = false;
        end
    end
    if (~isempty(self)) && ~ok
        fprintf( 1, 'Invalid optional arguments to %s.  Names and values must alternate.\n', ...
            self );
        fprintf( 1, '    %d %s\n', length(args), argToScriptString( args ) );
        error( mfilename() );
    end
end

function s = despace( s )
% Remove the spaces from s.
    s(s==' ') = [];
end
