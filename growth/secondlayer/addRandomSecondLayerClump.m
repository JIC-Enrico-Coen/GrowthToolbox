function mesh = addRandomSecondLayerClump( mesh, sz, ci, newci )
%mesh = addRandomSecondLayerClump( mesh, sz, ci, newci )
%   NOT USED.
%   Add a second layer clump of seven cells at a random position within the
%   finite element ci. If ci is omitted, a random finite element will be chosen.
%   The index of the new cells will start at newci; by default, this will be 1
%   more than the number of existing second layer cells.

    if nargin < 3
        ci = randi( [1, size(mesh.tricellvxs,1)] );
    end
    if nargin < 4
        newci = length( mesh.secondlayer.cells ) + 1;
    end
    
    bccentre = [1 1 1]/3;
    
    femVxs = mesh.nodes( mesh.tricellvxs( ci, : ), : );
    cellcentre = bccentre * femVxs;
    n = mesh.unitcellnormals(ci,:);
    J = makebasis( n );
    [cellpts,cellvxs] = clump7( rand(1)*pi*2, sz );
    numnewpts = size(cellpts,1);
    numnewcells = size(cellvxs,1);
    cellpts = [ zeros(numnewpts,1), cellpts ] * J';
    for i=1:size(cellpts,2)
        cellpts(:,i) = cellpts(:,i) + cellcentre(i);
    end
    bc = baryCoords( femVxs, n, cellpts );
    bc = normaliseBaryCoords( bc );
    numvx = size(bc,1);

    numvertexes = length( mesh.secondlayer.vxFEMcell );

    newvi = numvertexes+1 : numvertexes+numvx;
    
    mesh.secondlayer.cells = allocateCells(numnewcells);
    for i=1:size(cellvxs,1)
        nci = newci-1+i;
        mesh.secondlayer.cells(nci).vxs = cellvxs(i,:);
    end
    mesh.secondlayer.vxFEMcell(newvi) = ci;
    mesh.secondlayer.vxBaryCoords( newvi, 1:3 ) = bc;
    mesh.secondlayer.cell3dcoords( newvi, 1:3 ) = cellpts;
    if ~isempty( mesh.secondlayer.cellcolor )
        mesh.secondlayer.cellcolor(newci,:) = ...
            secondlayercolor( 1, mesh.globalProps.colorparams(2,:) );
        mesh.secondlayer.cellcolor((newci+1):(newci+numnewcells-1),:) = ...
            secondlayercolor( numnewcells-1, mesh.globalProps.colorparams(1,:) );
    end

    mesh = calcCloneVxCoords( mesh, newvi );
    mesh = completesecondlayer( mesh );
  % mesh = setSplitThreshold( mesh, 1.05, newci );
end

    
    
