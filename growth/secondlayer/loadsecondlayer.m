function m = loadsecondlayer( x, fi )
%m = loadsecondlayer( x, fi )
%   Load the Bio-A layer from Andy's data structure.
    if nargin < 3, fi = 1; end
    
% The second layer contains the following information:
% For each clone cell ci:
%       cells(ci).vxs(:)       A list of all its vertexes, in clockwise order.
%       cells(ci).edges(:)     A list of all its edges, in clockwise order.
%           These cannot be 2D arrays, since different cells may have
%           different numbers of vertexes or edges.
%       cellcolor(ci,1:3): Its colour.
%       celltargetarea(ci)     The cells' target areas.  Initially equal to
%                              their current areas.
%       cellarea(ci)           The cells' current areas.
%       areamultiple(ci)       A morphogen, initially 1.  The effective
%                              target area is areamultiple*celltargetarea.
% For each clone vertex vi:
% *      vxFEMcell(vi)          Its FEM cell index.
% *      vxBaryCoords(vi,1:3)   Its FEM cell barycentric coordinates.
% *      cell3dcoords(vi,1:3)   Its 3D coordinates (which can be calculated
%                              from the other data).
% For each clone edge ei:
%       edges(ei,1:4)          The indexes of the clone vertexes at its ends
%           and the clone cells on either side (the second one is 0 if absent).
%           This can be computed from the other data.

    setGlobals();
    m.nodes = [ x.X{fi}, zeros( size(x.X{fi},1), 1 ) ];
    m.tricellvxs = delaunay( x.X{fi}(:,1), x.X{fi}(:,2) );
    m = setmeshfromnodes( m, [] );
    m = leaf_deletepatch( m, [1] );  % UGLY HACK!!!

    numcells = length( x.cellind{fi} );
    numvxs = size( x.X{fi}, 1 );    
    
    m.secondlayer.cell3dcoords = ...
        [ x.X{fi}, zeros( numvxs, 1 ) ];
    hintcells = 1:size(m.tricellvxs,1);
    for vi=1:numvxs
        [ ci, bc, bcerr, abserr ] = findFE( m, m.secondlayer.cell3dcoords(vi,1:3), 'hint', hintcells );
        m.secondlayer.vxFEMcell(vi) = ci;
        m.secondlayer.vxBaryCoords(vi,1:3) = bc;
    end
    
    for ci=1:numcells
        m.secondlayer.cells(ci).vxs = x.cellind{fi}{ci};
    end
    
    m = completesecondlayer( m );
    m = upgrademesh( m );
end
