function h = plotOnCellGrid( ax, m, mode, maxcolor, mincolor, alph, data, falsescaling )
%plotOnCellGrid( ax, m, mode, maxcolor, data )
%   Given a per-vertex quantity perFEVertex (which can also be a morphogen
%   index or name), plot it over the cellular layer.
%
%   This is valid for foliate and volumetric meshes.

    if ~hasNonemptySecondLayer( m )
        h = [];
        return;
    end

    if nargin < 8
        falsescaling = 1;
    end

    switch lower(mode)
        case 'fevertex'
            perCellVertex = FEvertexToCellvertex( m, data );
        case 'fe'
            perCellVertex = FEToCellvertex( m, data );
        otherwise
            perCellVertex = data;
    end
    
    numcells = length(m.secondlayer.cells);
    allcellvxs = reshape( { m.secondlayer.cells.vxs }, [], 1 );
    maxlen = 0;
    for i=1:numcells
        maxlen = max( maxlen, length(m.secondlayer.cells(i).vxs) );
    end
    for i=1:numcells
        allcellvxs{i}((end+1):maxlen) = NaN;
    end
    faces = cell2mat(allcellvxs);
    
    maxPerCellVertex = max(abs(perCellVertex));
    if isempty(data) || all(maxPerCellVertex(:)==0)
        color = repmat( [1 1 1], size(m.secondlayer.cell3dcoords,1), 1 );
    elseif size(perCellVertex,2)==3
        color = perCellVertex;
    else
        if m.plotdefaults.autoColorRange
            maxval = [];
        else
            maxval = max(abs( m.plotdefaults.crange ));
        end
        if isempty( maxval ) || (maxval==0)
            perCellVertex = perCellVertex/maxPerCellVertex;
        else
            perCellVertex = perCellVertex/maxval;
        end
        if falsescaling ~= 1
            x = syntheticRange( maxPerCellVertex, falsescaling );
            perCellVertex = perCellVertex/(max(abs(x))/maxPerCellVertex);
        end
        poscolor = perCellVertex >= 0;
        color = zeros( length(perCellVertex), 3 );
        color(poscolor,:) = perCellVertex(poscolor)*maxcolor + (1-perCellVertex(poscolor))*[1 1 1];
        color(~poscolor,:) = -perCellVertex(~poscolor)*mincolor + (1+perCellVertex(~poscolor))*[1 1 1];
    end
    
    if m.plotdefaults.bioApointsize==0
        markeroptions = { 'Marker', 'none' };
    else
        markeroptions = { 'Marker', '.', 'MarkerSize', m.plotdefaults.bioApointsize };
    end
    
    h = patch( 'Parent', ax, 'Faces', faces, 'Vertices', m.secondlayer.cell3dcoords, ...
        'FaceVertexCData', color, 'FaceColor', 'interp', 'FaceAlpha', alph, 'LineWidth', m.plotdefaults.bioAlinesize, ...
        markeroptions{:} );
end
