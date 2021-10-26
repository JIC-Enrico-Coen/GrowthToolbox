function m = cutCells( m, cis )
%m = cutCells( m, cis )
%   cis is a set of indexes of cells of m.  Split m into two pieces,
%   consisting of the cells cis, and the rest.
%
%   This does not yet deal with places where the cells may be connected to
%   the rest of the mesh through nodes only and not vertexes.

    numnodes = size(m.nodes,1);
    numcells = size(m.tricellvxs,1);
    numedges = size(m.edgeends,1);
    
  % cis
  % cisnodes = m.tricellvxs(cis,:)
  % cisedges = m.celledges(cis,:)
    
    % Make a bitmap of the selected cells.
    cellmap = zeros(1,numcells);
    cellmap(cis) = 1;
    
    % Get all the boundary edges of the selected cells.  These are the
    % edges that occur as an edge of just one selected cell, and which have
    % another cell on their other side.
    ces = strikereps(reshape(m.celledges(cis,:),1,[]));
    ces = ces( m.edgecells(ces,2) > 0 );
  % ces
    
    % If there is no boundary there is nothing to do.
    % if isempty(ces), return; end
    
    % Get all the boundary nodes.  These are the endpoints of the boundary
    % edges.
    cns = unique( reshape( m.edgeends( ces, : ), 1, [] ) );
  % cns
    
    % Create new copies of the boundary nodes and edges.
    numnewnodes = length(cns);
    numnewedges = length(ces);
    nodesoldtonew = 1:numnodes;
    nodesoldtonew(cns) = numnodes + (1:numnewnodes);
  % nodesoldtonew
    edgesoldtonew = 1:numedges;
    edgesoldtonew(ces) = numedges + (1:numnewedges);
  % edgesoldtonew

    m.nodes = [ m.nodes ; m.nodes(cns,:) ];

    pcns = cns*2;
    pcns = [ pcns-1, pcns ];
    m.prismnodes = [ m.prismnodes ; m.prismnodes(pcns,:) ];

    m.morphogens = [ m.morphogens ; m.morphogens(cns,:) ];
    m.morphogenclamp = [ m.morphogenclamp ; m.morphogenclamp(cns,:) ];

    splitedgecells = m.edgecells(ces,:);
    for i=1:length(ces)
        if cellmap(splitedgecells(i,1))
            splitedgecells(i,:) = splitedgecells(i,[2 1]);
        end
    end
  % splitedgecells
    
    
    newedgecells = [splitedgecells(:,2), zeros(length(ces),1)];
  % newedgecells
    m.edgecells = [ m.edgecells; newedgecells ];
    m.edgecells(ces,:) = [splitedgecells(:,1), zeros(length(ces),1)];

    m.celledges(cis,:) = edgesoldtonew( m.celledges(cis,:) );

    newedgeends = nodesoldtonew( m.edgeends(ces,:) );
  % newedgeends
    m.edgeends = [ m.edgeends ; newedgeends ];
    % Update the endpoints of old edges in the new region.
    cisedges = unique( reshape( m.celledges( cis, : ), 1, [] ) );
    cisedges = cisedges( cisedges <= numedges );
    m.edgeends(cisedges,:) = nodesoldtonew( m.edgeends(cisedges,:) );

    m.tricellvxs(cis,:) = nodesoldtonew( m.tricellvxs(cis,:) );
    
    % Now we must look for places where the patch is still connected to the
    % rest of the mesh through single vertexes.
    patchnodes = unique( reshape( m.tricellvxs(cis,:), 1, [] ) );
    patchnodes = patchnodes( patchnodes <= numnodes );
    cellmap = true(1,numcells);
    cellmap(cis) = false;
    othernodes = unique( reshape( m.tricellvxs(cellmap,:), 1, [] ) );
    splitnodes = intersect( patchnodes, othernodes )
    
    
    validmesh(m);
end

function a = strikereps( a )
%a = strikereps( a )
%   Delete all repeated elements from the vector A.

    a = sort(a);
    last = a(1);
    b = true(size(a));
    for i=2:length(a)
        if a(i)==last
            b(i-1) = false;
            b(i) = false;
        end
        last = a(i);
    end
    a = a(b);
end
