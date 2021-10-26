function m = leaf_createmesh( m, nodes, triangles, varargin )
%m = leaf_createmesh( m, nodes, triangles )
%   Create a new mesh from a given set of vertexes and triangles.
%
%   Arguments:
%       M is either empty or an existing mesh.  If it is empty, then an
%       entirely new mesh is created, with the default set of morphogens.
%       If M is an existing mesh, then its geometry is replaced by the new
%       mesh.  It retains the same set of morphogens (all set to zero
%       everywhere on the new mesh), interaction function, and all other
%       properties not depending on the specific geometry of the mesh.
%
%       NODES is an N*3 matrix containing N points in 3D space. These are
%       the vertexes of the new mesh.
%
%       TRIANGLES is an M*3 matrix containing triples of indexes of points
%       in NODES. These must be consistently oriented.
%
%       All arguments must be present.
%
%   Options: None.
%
%   Equivalent GUI operation: none.
%
%   Topics: Mesh creation.

    if nargin < 3
        fprintf( 1, '%s: Not enough arguments (3 expected, %d found.\n', ...
            mfilename(), nargin );
        if nargin==0
            m = [];
        elseif ~isstruct(m)
            m = [];
        end
        return;
    end
    [s,ok] = safemakestruct( mfilename(), varargin );
    setGlobals();
    ok = checkcommandargs( mfilename(), s, 'exact' );
    if ~ok, return; end
    
    maxtri = max(triangles(:));
    if maxtri > size(nodes,1)
        complain( '%s: invalid triangles: maximum index is %d, but only %d nodes provided.', ...
            mfilename(), maxtri, size(nodes,1) );
        return;
    end
    if any(triangles(:) < 1)
        complain( '%s: invalid triangles: some indexes are less than 1.', ...
            mfilename() );
        return;
    end
    alltrinodes = unique(reshape(triangles,1,[]));
    if length(alltrinodes) < size(nodes,1)
        complain( '%s: %d nodes not referenced by the triangles: ignored.', ...
            mfilename(), size(nodes,1) - length(alltrinodes) );
        reindex = zeros(1,size(nodes,1));
        reindex(alltrinodes) = 1:length(alltrinodes);
        nodes = nodes(alltrinodes,:);
        triangles = reindex(triangles);
    end
    numtri = size(triangles,1);
    edges = sortrows( [ [ triangles(:,[1 2]), (1:numtri)' ]; ...
                        [ triangles(:,[2 3]), (1:numtri)' ]; ...
                        [ triangles(:,[3 1]), (1:numtri)' ] ] );
    edgediffs = edges(2:end,[1 2]) - edges(1:(end-1),[1 2]);
    conflicts = find( all(edgediffs==0,2) );
    triangleconflicts = [ edges(conflicts,3), edges(conflicts+1,3) ];
    if any(all(edgediffs==0,2))
        complain( '%s: triangles are not consistently oriented.', mfilename );
        fprintf( 1, '    Triangles %d and %d conflict.\n', triangleconflicts' );
        return;
    end
    newm = struct( 'nodes', nodes, 'tricellvxs', triangles );
    [m,ok] = setmeshfromnodes( newm, m );
    if ~ok
        complain( '%s: Mesh is invalid. Proceed with caution.', mfilename() );
    end
    m.meshparams = struct( 'type', 'custom', 'randomness', 0 );
end

