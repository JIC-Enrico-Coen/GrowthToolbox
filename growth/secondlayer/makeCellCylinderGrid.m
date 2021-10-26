function m = makeCellCylinderGrid( m, celldiameter, allowoveredge )
%m = makeCellCylinderGrid( m, celldiameter, allowoveredge )
%   Cover a mesh, assumed to be roughly cylindrical, with a cylindrical
%   grid of cells.
%
%   allowoveredge is not implemented.

    numnodes = getNumberOfVertexes( m );
    meshcentrexy = sum( m.nodes(:,[1 2]), 1 )/numnodes;
    zmin = min(m.nodes(:,3));
    zmax = max(m.nodes(:,3));
    centre1 = [ meshcentrexy, zmin ];
    centre2 = [ meshcentrexy, zmax ];
    stepsup = ceil( (zmax-zmin)/celldiameter );
    meanradius = sum(sqrt(sum(m.nodes(:,[1 2]).^2,2)))/numnodes;
    stepsaround = ceil( meanradius*2*pi/celldiameter );
    [vxs,cells,origins] = cellgridcylinder( ...
        'centre1', centre1, 'centre2', centre2, ...
        'divs', stepsaround, 'rings', stepsup, ...
        'havecylinder', true, 'havecap1', false, 'havecap2', false );
    [ipts,whichpoly,bcs] = projectPointsToMesh( m.nodes, m.tricellvxs, vxs, origins );
%       cells(:).vxs(:)
%       vxFEMcell(:)
%       vxBaryCoords(:,1:3)
%       cell3dcoords(:,1:3)
    m.secondlayer = newemptysecondlayer();
    m.secondlayer.cells = struct( 'vxs', [] );
    m.secondlayer.cells(size(cells,1)) = struct( 'vxs', [] );
    for i=1:size(cells,1)
        m.secondlayer.cells(i).vxs = cells(i,:);
    end
    m.secondlayer.vxFEMcell = whichpoly;
    m.secondlayer.vxBaryCoords = bcs;
    m.secondlayer.cell3dcoords = ipts;
end
