function m = leaf_onecell3D( m, varargin )
%m = leaf_onecell3D( m, ... )
%   Make a mesh consisting of a single finite element of any type.
%
%   Arguments:
%       M is either empty or an existing mesh.  If it is empty, then an
%       entirely new mesh is created, with the default set of morphogens.
%       If M is an existing mesh, then its geometry is replaced by the new
%       mesh.  It retains the same set of morphogens (all set to zero
%       everywhere on the new mesh), interaction function, and all other
%       properties not depending on the specific geometry of the mesh.
%
%   Options:
%
%   'type': A finite element type.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'type', 'H8' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'type' );
    if ~ok, return; end

    fe = FiniteElementType.MakeFEType(s.type);
    newm.FEnodes = fe.canonicalVertexes;
    newm.FEsets = struct( 'fe', fe, ...
                       'fevxs', 1:size(fe.canonicalVertexes,1) );
    m = newm; % replaceNodes( m, newm );
                   
    m = completeVolumetricMesh( m );
end
