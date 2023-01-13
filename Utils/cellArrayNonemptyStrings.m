function cs = cellArrayNonemptyStrings( varargin )
%cs = cellArrayNonemptyStrings( varargin )
%   Make the given strings into a cell array of size N*1, containing only
%   the nonempty strings.

    cs = cell( nargin, 1 );
    csi = 0;
    for i=1:nargin
        if ~isempty( varargin{i} )
            csi = csi+1;
            cs{csi} = varargin{i};
        end
    end
    cs((csi+1):end) = [];
end
