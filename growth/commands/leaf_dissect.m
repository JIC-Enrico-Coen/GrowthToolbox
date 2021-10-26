function m = leaf_dissect( m, varargin )
%m = leaf_dissect( m )
%   Cut m along all of its seam edges.
%
%   Options:
%
%       deletesize:  After cutting the seams, every component containing
%                    this number or fewer elements will 
%                    be deleted. The default value is 1. If the value given
%                    would mean that every component is deleted, a single
%                    component containing the largest number of elements
%                    will be retained.
%
%   Topics: Mesh editing, Seams.

    if isempty(m)
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'deletesize', 1 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'deletesize' );
    if ~ok, return; end

    m = dissectmesh( m, 0, s.deletesize );
end
