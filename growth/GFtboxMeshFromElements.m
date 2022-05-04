function m = GFtboxMeshFromElements( m, vxs, vxsets, fetype, add )
%m = GFtboxMeshFromElements( vxs, polys )
%   VXS is an N*3 array defining a set of N vertexes.
%   VXSETS is a P*K set of vertex indexes, defining a set of P finite
%   elements with K vertexes each.
%   FETYPE is the type of the finite elements.
%
%   This procedure constructs a GFtbox mesh from these finite elements.
%   If M is empty, a completely new mesh will be created.
%   If M is nonempty, its existing elements will be replaced by the new
%   ones if ADD is false (the default), or they will be retained alongside
%   the new ones. In either case, whatever morphogens M has will be
%   extended to the new mesh.
%
%   This procedure is for volumetric meshes only.

    if isempty(m) || (nargin < 4)
        add = false;
    end
    
    newm = struct( 'FEnodes', vxs, ...
                   'FEsets', struct( 'fe', FiniteElementType.MakeFEType(fetype), ...
                                     'fevxs', vxsets ) );
    
    if isempty(m)
        m = completeVolumetricMesh( newm );
    else
        m = replaceNodes( m, newm, add );
    end
end