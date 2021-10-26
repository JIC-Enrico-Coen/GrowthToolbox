function [pcells,pcentres] = plotVoronoi( ax, cells, cellvxs, centres, varargin )
    numcells = length(cells);
    totlen = 0;
    for i=1:numcells
        totlen = totlen + length(cells{i} );
    end
    pts = NaN( totlen+numcells*2, size(cellvxs,2) );
    curindex = 0;
    for i=1:numcells
        if ~isempty( cells{i} )
            pts( (curindex+1):(curindex+length(cells{i})+1), : ) = cellvxs( [cells{i} cells{i}(1)], : );
        end
        curindex = curindex + length(cells{i}) + 2;
    end

    if size(pts,2) < 3
        pts(end,3) = 0;
        pts( isnan(pts(:,1)), (size(pts,2)+1):3 ) = NaN;
    end
    
    wasHolding = ishold( ax );
    if ~wasHolding
        cla(ax);
    end
    hold( ax, 'on' );
    pcentres = plotpts( ax, centres, 'o' );
    pcells = patch( pts(:,1), pts(:,2), pts(:,3), 'Parent', ax, varargin{:} );
    hold( ax, boolchar( wasHolding, 'on', 'off' ) );
end
