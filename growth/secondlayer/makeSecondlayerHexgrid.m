function m = makeSecondlayerHexgrid( m, numouterrows, numalongrow )
%m = makeSecondlayerHexgrid( m, celldiam )
%   Make a bio layer for m consisting of a regular grid of hexagons.
%   This assumes that the tissue layer of m is rectangular and flat in the
%   XY plane.
%
%   CELLDIAM is the distance between opposite vertexes of a hexagonal cell.

    m.secondlayer = deleteSecondLayerCells( m.secondlayer );

    bbox = [ min(m.nodes(:,[1 2])), max(m.nodes(:,[1 2])) ];
    width = bbox(3) - bbox(1);
    height = bbox(4) - bbox(2);
    centre = (bbox([1 2]) + bbox([3 4]))/2;
    
%     bigsize = [width  height];
%     smallsize = celldiam*[sqrt(3)/4, 1 ];
%     margins = celldiam*[sqrt(3)/4, 1/2];
%     numrects = fitRectInRect( smallsize, bigsize, margins );
%     numxvals = numrects(1)*2;
%     numyvals = numrects(2)*2;
    
    numxvals = (numalongrow+1)*2;
    numyvals = numouterrows*2;
    maxXcelldiam = width*2/(sqrt(3)*(numalongrow + 1/2));
    maxYcelldiam = height*2/(3*numouterrows - 1);
    celldiam = min( maxXcelldiam, maxYcelldiam );
    smallsize = celldiam*[sqrt(3)/4, 1 ];
    
    horizspacing = smallsize(1);
    
    xvals = ((1:numxvals) - (1+numxvals)/2) * horizspacing + centre(1);
    yvals = (1:numyvals);
    yvals = [ yvals; yvals+1/3 ];
    yvals = yvals*(celldiam*3/4);
    yvals = yvals + (centre(2) - (yvals(1)+yvals(end))/2);
    yvals1a = yvals(1:4:end);
    yvals2a = yvals(2:4:end);
    yvals2b = yvals(3:4:end);
    yvals1b = yvals(4:4:end);
    yvals1 = reshape( [ yvals1a; yvals1b ], 1, [] );
    yvals2 = reshape( [ yvals2a; yvals2b ], 1, [] );
    numvxs = length(xvals) * length(yvals1)/2 - 2;
    
    vxs = zeros( numvxs, 3 );
    vi = 0;
    e = zeros(0,2);
    numcells = numalongrow * (numyvals - 1);
    cells = struct();
    cells(numcells).vxs = [];
    ci = 0;
    cellpattern = [1 2 2 2 1 1] + [0 0 1 2 2 1]*numyvals;
    lastcellpattern = [1 2 2 1 0 1] + [0 0 1 2 2 1]*numyvals;
    for cy = 1:(numyvals - 1)
        if mod(cy,2)==0
            offset = 1;
        else
            offset = 0;
        end
        for cx = 1:numalongrow
            if offset && (cx==numalongrow)
                cp = lastcellpattern;
            else
                cp = cellpattern;
            end
            ci = ci+1;
            column = (cx-1)*2 + offset;
            cells(ci).vxs = cp + (cy-1) + column*numyvals;
        end
    end
    for i=1:numxvals
        if mod(i,2)==0
            if i==numxvals
                ys = yvals1(2:(end-1));
                ve = [ (1:2:(numyvals-3))', (2:2:(numyvals-2))' ];
            else
                ys = yvals1;
                ve = [ (2:2:(numyvals-2))', (3:2:(numyvals-1))' ];
            end
        else
            ys = yvals2;
            ve = [ (1:2:(numyvals-1))', (2:2:numyvals)' ];
        end
        e = [ e; ((i-1)*numyvals + ve) ];
        if i > 1
            if i==numxvals
                he = [ (2:(numyvals-1))', ((numyvals+1):(2*numyvals-2))' ];
            else
                he = [ (1:numyvals)', ((numyvals+1):(2*numyvals))' ];
            end
            e = [ e; ((i-2)*numyvals + he) ];
        end
        x = xvals(i);
        nvxs = length(ys);
        vxs( (vi+1):(vi+nvxs), 1 ) = x;
        vxs( (vi+1):(vi+nvxs), 2 ) = ys;
        vi = vi+nvxs;
    end
    % vi should equal numvxs.
    
%       cells(:).vxs(:)
%       vxFEMcell(:)
%       vxBaryCoords(:,1:3)
%       cell3dcoords(:,1:3)

    m.secondlayer.cells = cells;
    m.secondlayer.cell3dcoords = vxs;
end

function numrects = fitRectInRect( smallsize, bigsize, margins )
    numrects = floor( (bigsize + margins)./(smallsize + margins) );
end
