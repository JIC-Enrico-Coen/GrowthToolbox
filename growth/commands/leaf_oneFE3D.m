function m = leaf_oneFE3D( m, varargin )
%m = leaf_block3D( m, ... )
%   Make a mesh consisting of an axis-aligned rectangular block divided
%   into hexahedral finite elements.
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
%   'size': A 3-element vector, default [2 2 2].  This specifies the
%       dimensions of the block.
%
%   'position': A 3-element vector, default [0 0 0]. This specifies the
%       position of the centre of the block. 
%
%   'divisions': A 3-element vector of positive integers, default [2 2 2].
%       This specifies how many finite elements it is divided into along
%       each dimension.
%
%   'type': A finite element type.  Possibilities are 'H8' (the default),
%       and others to be implemented.  'H8' specifies that the block is to
%       be made of linear hexahedra. 'T4' and 'T4Q' specify linear or
%       quadratic tetrahedra respectively (combining in threes to make
%       blocks).  'P6' specifies linear pentahedra (combining in pairs to
%       make blocks).

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'type', 'H8' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'type' );
    if ~ok, return; end

    m.FEsets = struct( 'fe', FiniteElementType.MakeFEType(s.type) );
    m.FEnodes = m.FEsets.fe.canonicalVertexes;
    m.FEsets.fevxs = 1:size(m.FEnodes,1);
                   
    m = completeVolumetricMesh( m );
end
