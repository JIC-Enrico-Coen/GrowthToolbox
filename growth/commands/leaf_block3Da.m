function [m,ok] = leaf_block3Da( m, varargin )
%m = leaf_block3Da( m, ... )
%   Make a mesh consisting of an axis-aligned rectangular block divided
%   into volumetric finite elements. This differens from leaf_block3D by
%   subdividing each cube into tetrahedra by a different method.
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
%   All the options for geom_block3D, plus:
%
%   'new':  A boolean, true by default.  If M is
%       empty, true is implied.  True means that an
%       entirely new mesh is created.  False means that
%       new geometry will be created, which will replace
%       the current geometry of M, but leave M with the
%       same set of morphogens and other parameters as it
%       had previously.  (NOT IMPLEMENTED)
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BLOCK3D,
%           LEAF_SPHERE3D, LEAF_ICOSAHEDRON3D.
%
%   Topics: Mesh creation.

    if nargin==0
        m = [];
        ok = false;
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok
        return;
    end
    
    if isfield( s, 'new' )
        isnew = s.new;
        s = rmfield( s, 'new' );
    else
        isnew = true;
    end
    
    [vxs,vxsets,s,ok] = geom_block3D( s );
    if ~ok
        return;
    end
    
    setGlobals();
    
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m );
    if ~ok
        return;
    end

    savedstate.replot = true;
    savedstate.install = true;
    if isnew
        m = [];
    end

    newm.FEnodes = vxs;
    newm.FEsets = struct( 'fe', FiniteElementType.MakeFEType(s.type), ...
                       'fevxs', vxsets );
    if isempty(m)
        m = completeVolumetricMesh( newm );
    else
        m = replaceNodes( m, newm );
    end
    
    locorner = s.position-s.size/2;
    hicorner = s.position+s.size/2;
    delta = s.size ./ (s.divisions*4);
    v_xlo = vxs(:,1) <= locorner(1) + delta(1);
    v_xhi = vxs(:,1) >= hicorner(1) - delta(1);
    v_ylo = vxs(:,2) <= locorner(2) + delta(2);
    v_yhi = vxs(:,2) >= hicorner(2) - delta(2);
    v_zlo = vxs(:,3) <= locorner(3) + delta(3);
    v_zhi = vxs(:,3) >= hicorner(3) - delta(3);
    vxcornerness = v_xlo + v_xhi + v_ylo + v_yhi + v_zlo + v_zhi;
    m.sharpedges = all( vxcornerness( m.FEconnectivity.edgeends ) > 1, 2 );
    m.sharpvxs = vxcornerness > 2;
    
    m = concludeGUIInteraction( handles, m, savedstate );
end

