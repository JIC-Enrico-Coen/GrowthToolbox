function varargout = FindMorphogenRole( m, varargin )
%varargout = FindMorphogenRole( m, varargin )
%   Find the index of any morphogen role or roles.  Invalid role names are
%   mapped to zero.  
%
%   The last argument can be a boolean.  If true (the default is false),
%   FindMorphogenRole will give a warning about requested roles for which
%   no morphogen is assigned.
%
%   The number of output arguments should be either 1 (in which case the
%   indexes are returned as a single array) or one per requested index.

    foo = FindIndexes( m.roleNameToMgenIndex, varargin{:} );
    if nargout==1
        varargout{1} = foo;
    elseif nargout > 1
        varargout = num2cell(foo);
    else
        varargout = {};
    end
    return;

    if isempty( m ) || isempty( varargin )
        varargout{1} = [];
        return;
    end
    if islogical( varargin{end} )
        complain = varargin{end};
        varargin(end) = [];
    else
        complain = false;
    end
    if iscell(varargin{1})
        roles = varargin{1};
    else
        roles = varargin;
    end
    mgenIndex = zeros( 1, length(roles) );
    numresults = nargout();
    for i=1:length(roles)
        role = upper(roles{i});
        if isfield( m.roleNameToMgenIndex, role )
            mgenIndex(i) = m.roleNameToMgenIndex.(role);
        elseif complain
            fprintf( 1, '%s: No such role as "%s".\n', 'FindMorphogenRole', role );
        end
    end
    if numresults <= 1
        varargout{1} = mgenIndex;
    else
        varargout = num2cell( mgenIndex );
    end
end
