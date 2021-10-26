function r = getVertexRadii( m, centre )
%r = getVertexRadii( m )
%   Get the radius of every vertex of m.  If centre is provided, radii are
%   relative to that point.

    if isVolumetricMesh(m)
        nodefield = 'FEnodes';
    else
        nodefield = 'nodes';
    end
    if nargin < 2
        r = sqrt( sum( m.(nodefield).^2, 2 ) );
    else
        r = sqrt( sum( (m.(nodefield) - repmat(centre,getNumberOfVertexes(m),1)).^2, 2 ) );
    end
end
