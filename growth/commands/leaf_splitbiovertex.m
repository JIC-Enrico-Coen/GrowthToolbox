function m = leaf_splitbiovertex( m, vis, frac )
%m = leaf_splitbiovertex( m, vis, frac )
%   vis is a list of indexes of vertexes of the bio layer.
%   Each of the vertexes will be split into one vertex for every
%   bio cell it belongs to, making a small air space where there was
%   formerly a junction.  Vertexes on the border of the bio layer are
%   ignored.
%
%   frac is a value determining the placement of the new vertexes along
%   their edge.  0 corresponds to no movement, 0.5 to halfway along. With
%   the current implementation, frac should always be greater than 0 and
%   less than 0.5.  Values outside this range will result in the procedure
%   doing nothing.

    if nargin < 3
        frac = 0.2;
    end

    if (frac <= 0) || (frac >= 0.5)
        return;
    end
    
%     vis = unique(vis(:)');
%     vis = vis(end:-1:1);
    vis = unique(vis(:)');
    vis = vis(end:-1:1);
%     for vi=vis

    % Find all of the edges that the vertex belongs to,
    e = m.secondlayer.edges(:,[1 2]);
    nvi = zeros(length(vis),1);
    evi = cell(length(vis),1);
    for i=1:length(vis)
        evi{i} = find(any(e==vis(i),2));
        nvi(i) = length(evi{i});
    end
    vis = vis(nvi>=3);
    if isempty(vis)
        return;
    end
    evi = evi(nvi>=3);
    
    for i=1:length(vis)
        vi = vis(i);
        ev = evi{i}; % edges containing vi.
        degree = length(ev);
        evdata = m.secondlayer.edges(ev,:);
        if any(evdata(:,4) == 0) % Allow air spaces.
            continue;
        end
        foo = evdata(:,2)==vi;
        evdata(foo,:) = evdata(foo,[2 1 4 3]);
%         othervi = evdata(:,2);
%         cell1 = evdata(:,3);
%         cell2 = evdata(:,4);
        [~,edgeperm] = makechains( evdata(:,[2 3 4]) );
        ev = ev(edgeperm);
        evdata = evdata(edgeperm,:);
        nvxs = length(m.secondlayer.vxFEMcell);
        nedges = size(m.secondlayer.edges,1);
        newvxs = [ vi, ((nvxs+1):(nvxs+degree-1)) ]';
        evdata(:,1) = newvxs;
        newvxs1 = newvxs( [end 1:(end-1)] );
        newvxs12 = [ newvxs1, newvxs ];
        newedges = (nedges+1):(nedges+degree);
        newedgedata = [ newvxs12, evdata(:,3), zeros(degree,1)-1 ];
        for j=1:degree
            cj = evdata(j,3);
            if cj ~= -1
                celldata = m.secondlayer.cells(cj);
                cvi = find(celldata.vxs==vi,1);
                celldata.vxs = [ celldata.vxs(1:(cvi-1)), ...
                                 newvxs12( j, : ), ...
                                 celldata.vxs((cvi+1):end) ];
                celldata.edges = [ celldata.edges(1:(cvi-1)), ...
                                   newedges( j ), ...
                                   celldata.edges(cvi:end) ];
                m.secondlayer.cells(cj) = celldata;
            end
            % Insert a pair of vertexes from newvxs in place of vi.
            % Insert a new edge in the same place in the edge list.
        end
        flip = evdata(:,3) <= 0;
        evdata( flip, : ) = evdata( flip, [2 1 4 3] );
        m.secondlayer.edges( ev, : ) = evdata;
        m.secondlayer.edges = [ m.secondlayer.edges; newedgedata ];
        vxspos = m.secondlayer.cell3dcoords( evdata(:,2), : );
        vxpos = m.secondlayer.cell3dcoords( vi, : );
        newvxspos = frac*vxspos + repmat( (1-frac)*vxpos, degree, 1 );
        m.secondlayer.cell3dcoords( newvxs, : ) = newvxspos; % Calculate positions of new vertexes.
        fes = zeros(degree,1);
        bcs = zeros(degree,3);
        hint = m.secondlayer.vxFEMcell( vi );
        for j=1:degree
            [ fes(j), bcs(j,:), ~, ~ ] = findFE( m, newvxspos(j,:), 'hint', hint );
        end
        m.secondlayer.vxFEMcell( newvxs ) = fes;
        m.secondlayer.vxBaryCoords( newvxs, : ) = bcs;
        m.secondlayer.generation( newedges ) = 0;
        m.secondlayer.edgepropertyindex( newedges ) = m.secondlayer.newedgeindex;
        m.secondlayer.interiorborder( newedges ) = false;
        
        % xxxx = 1;
    end
    
%     end
end
