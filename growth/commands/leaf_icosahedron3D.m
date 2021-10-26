function m = leaf_icosahedron3D( m, varargin )
%m = leaf_icosahedron3d( m, ... )
%   Create a new icosahedral volumetric mesh.
%
%   Arguments:
%       M is either empty or an existing mesh.  If it is empty, then an
%       entirely new mesh is created, with the default set of morphogens
%       If M is an existing mesh, then its geometry is replaced by the new
%       mesh.  It retains the same set of morphogens (all set to zero
%       everywhere on the new mesh), interaction function, and all other
%       properties not depending on the specific geometry of the mesh.
%
%   Options:
%       'radius'        The radius of the icosahedron.  Default 1.
%       'type'          The type of the finite elements to use. Default is
%                       'T4Q' (quadratic first-order tetrahedra).
%       'hemisphere'    Whether to make half an icosahedron.  Default
%                       false.
%       'new'           A boolean, true by default.  If M is
%                       empty, true is implied.  True means that an
%                       entirely new mesh is created.  False means that
%                       new geometry will be created, which will replace
%                       the current geometry of M, but leave M with the
%                       same set of morphogens and other parameters as it
%                       had previously
%   'type': A finite element type.  Possibilities are 'T4Q' (the default),
%       or 'T4'.  The type must be that of a tetrahedral element.
%
%
%   Example:
%       m = leaf_circle( [], 'radius', 2, 'rings', 4 );
%
%   Equivalent GUI operation: selecting "Circle" or "Hemisphere" on the
%   pulldown menu on the "Mesh editor" panel, and clicking the "New" or
%   "Replace" button.
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'radius', 1, 'type', 'T4Q', 'hemisphere', false, 'new', true );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'radius', 'type', 'hemisphere', 'new' );
    if ~ok, return; end
    
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m );
    if ~ok, return; end
    savedstate.replot = true;
    savedstate.install = true;
    if s.new
        m = [];
    elseif isempty(m)
        s.new = true;
    end
    
    fe = FiniteElementType.MakeFEType(s.type);
    if (fe.typeparams.numboxdims ~= 0) || (fe.typeparams.numsimplexdims ~= 3)
        fprintf( 1, '**** %s: finite element type must be tetrahedral, ''%s'' was given.\n', ...
            mfilename(), s.type );
        return;
    end
    
    [vxs,trivxs] = icosahedronGeometry();
    vxs = [ [0 0 0]; vxs*s.radius ];
    tetravxs = [ trivxs+1, ones(20,1)];
    
    if s.hemisphere
        phi = (1+sqrt(5))/2;
        s3 = sqrt(3);
        c = 1/(phi*s3);
        s = phi/s3;
        rot = [1 0 0;
               0 c s;
               0 -s c];
        vxs = vxs * rot;
        
        % Delete bottom face vertexes.
        % Flatten mid vertexes.
        bottomvxs = vxs(:,3) < -0.7;
        topvxs = vxs(:,3) > 0.7;
        mid = ~(bottomvxs | topvxs);
        vxs(mid,3) = 0;
        deletetetras = any( bottomvxs(tetravxs), 2 );
        tetravxs = tetravxs( ~deletetetras, : );
        keepvxs = unique( tetravxs(:) );
        renumbervxs = zeros(size(vxs,1),1);
        renumbervxs(keepvxs) = 1:length(keepvxs);
        tetravxs = renumbervxs(tetravxs);
        vxs = vxs(keepvxs,:);
    end
    
    newm.FEnodes = vxs;
    newm.FEsets = struct( 'fe', fe, ...
                          'fevxs', tetravxs );
    if isempty(m)
        m = completeVolumetricMesh( newm );
    else
        m = replaceNodes( m, newm );
    end
                   
    m = concludeGUIInteraction( handles, m, savedstate );
end
