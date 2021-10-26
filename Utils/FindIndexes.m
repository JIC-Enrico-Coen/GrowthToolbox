function varargout = FindIndexes( name2index, varargin )
%varargout = FindIndexes( name2index, varargin )
%   Find the index of a name in a dictionary.  varargin can be a cell array
%   of names, or a single name.  Invalid names are mapped to zero.  
%
%   The last argument can be a boolean.  If true (the default is false),
%   FindIndexes will give a warning about requested names for which
%   no index is assigned.

    if isempty( name2index ) || isempty( varargin )
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
        names = varargin{1};
    else
        names = varargin;
    end
    indexes = zeros( 1, length(names) );
    numresults = nargout();
    for i=1:length(names)
        role = upper(names{i});
        if isfield( name2index, role )
            indexes(i) = name2index.(role);
        elseif complain
            fprintf( 1, '%s: No such role as "%s".\n', 'FindMorphogenRole', role );
        end
    end
    if numresults <= 1
        varargout{1} = indexes;
    else
        varargout = num2cell( indexes );
    end
end
