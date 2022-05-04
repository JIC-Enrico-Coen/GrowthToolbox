function m = calcCloneVxCoords( m, vxs )
%m = calcCloneVxCoords( m, vxs )
%   Calculate the 3D coordinates of a list of clone vertexes and install them
%   in the mesh.

    if ~hasNonemptySecondLayer( m ), return; end

    numvxs = length( m.secondlayer.vxFEMcell );
    if nargin < 2
        vxs = 1:numvxs;
    end
    if ~isfield( m.secondlayer, 'cell3dcoords' )
        m.secondlayer.cell3dcoords = zeros(0,3, 'single');
    end
    m.secondlayer.cell3dcoords( vxs, : ) = findCloneVxCoords( m, vxs );
end
