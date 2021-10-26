function m = separateBioVertexes( m, shiftamount )
%m = separateBioVertexes( m )
%   Wherever a vertex of the bio layer is the sole connection between two
%   or more sets of cells, they having no edge in common, split the vertex
%   into multiple copies, one for each edge-connected set.

    % For each vertex, count the number of edges NE and the number of cells
    % NC it is part of.  If NE-NC is greater than 1 then the vertex belongs
    % to NE-NC components.
    
    if nargin < 2
        shiftamount = 0.1;
    end
    
    numvxs = length( m.secondlayer.vxFEMcell );
    numedges = size( m.secondlayer.edges, 1 );
    
    ve = unique( sortrows( [ reshape( m.secondlayer.edges(:,[1,2]), [], 1 ), repmat( (1:numedges)', 2, 1 ) ] ), 'rows' );
    ejumps = find( ve(1:(end-1),1) ~= ve(2:end,1) );
    estarts = [ 1; ejumps+1 ];
    eends = [ ejumps; size(ve,1) ];
    edgespervertex = eends-estarts+1;  % Should have same length as numvxs.
    
    vc = sortrows( unique( [ m.secondlayer.edges(:,[1,3]);
                             m.secondlayer.edges(:,[1,4]);
                             m.secondlayer.edges(:,[2,3]);
                             m.secondlayer.edges(:,[2,4]) ], 'rows' ) );
    vc( vc(:,2)<=0, : ) = [];
    
    
    
    cjumps = find( vc(1:(end-1),1) ~= vc(2:end,1) );
    cstarts = [ 1; cjumps+1 ];
    cends = [ cjumps; size(vc,1) ];
    cellspervertex = cends-cstarts+1;
    
    vcee = sortrows( makeVCEE( m ) );
    vceejumps = find( vcee(1:(end-1),1) ~= vcee(2:end,1) );
    vceestarts = [ 1; vceejumps+1 ];
    vceeends = [ vceejumps; size(vcee,1) ];

    
    
    
    
    excesspervertex = edgespervertex - cellspervertex;
    vertexestoprocess = find( excesspervertex > 1 );
    numtoprocess = length(vertexestoprocess);

    numvxstoplace = sum(excesspervertex(vertexestoprocess));
    numnewvxs = numvxstoplace - numtoprocess;
    numtotalvxs = numvxs + numnewvxs;
    if numnewvxs > 0
        m.secondlayer.vxFEMcell(numtotalvxs) = 0;
        m.secondlayer.vxBaryCoords(numtotalvxs,:) = 0;
        m.secondlayer.cell3dcoords(numtotalvxs,:) = 0;
    end
    newvxsused = 0;
    for i=1:numtoprocess
        vi = vertexestoprocess(i);
        oldvxpos = m.secondlayer.cell3dcoords(vi,:);
        vcees = vcee(vceestarts(vi):vceeends(vi),[2 3 4]);
        [ch,~] = makechains( vcees );
        clumpdelimiters = find( ch(2,:)==0 );
        clumpstarts = [ 1, clumpdelimiters(1:end-1)+1 ];
        clumpends = clumpdelimiters-1;
        if length(clumpdelimiters) <= 1
            continue;
        end
        for j=1:length(clumpdelimiters)
            clumpedges = ch(1,clumpstarts(j):clumpdelimiters(j));
            clumpedgedata = m.secondlayer.edges( clumpedges, : );
            clumpcells = ch(2,clumpstarts(j):clumpends(j));
            if j==1
                nvi = vi;
            else
                newvxsused = newvxsused+1;
                nvi = numvxs+newvxsused;
            end
            viInEdgedata = clumpedgedata(:,[1 2])==vi;
            othervxs = clumpedgedata(~viInEdgedata);
            othervxspos = m.secondlayer.cell3dcoords(othervxs,:);
            otherposavg = sum(othervxspos,1)/size(othervxspos,1);
            newvxpos = (1-shiftamount)*oldvxpos + shiftamount*otherposavg;
            m.secondlayer.cell3dcoords(nvi,:) = newvxpos;
            [ m.secondlayer.vxFEMcell(nvi), m.secondlayer.vxBaryCoords(nvi,:), ~, ~ ] = findFE( m, newvxpos, 'hint', m.secondlayer.vxFEMcell(vi) );
            if j>1
                % Replace vi by nvi in each cell in clumpcells.
                for k=1:length(clumpcells)
                    vxs = m.secondlayer.cells(clumpcells(k)).vxs;
                    vxs(vxs==vi) = nvi;
                    m.secondlayer.cells(clumpcells(k)).vxs = vxs;
                end
                % Replace vi by nvi in each edge in clumpedgedata.
                clumpedgedata(viInEdgedata) = nvi;
                m.secondlayer.edges( clumpedges, : ) = clumpedgedata;
            end
        end
    end
    
    % It remains to add the new vertexes to the structure and calculate
    % their positions.
end