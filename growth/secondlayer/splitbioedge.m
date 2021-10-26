function m = splitbioedge( m, eis )
%m = splitbioedge( m, eis )
%   eis is a list of edges of the bio layer that will potentially be split.
%   An edge in this list will only be split if it (1) has a cell on both
%   sides, and (2) has one air space at each end.
%
%   NEVER USED.

    if isempty(m)
        return;
    end
    
    twosided = m.secondlayer.edges(eis,4) > 0;
    eis = eis(twosided);
    eis = validends( m, eis );
    if isempty(eis)
        return;
    end
    % m.secondlayer does not contain much connectivity information. It has:
    %   edges: lists the vertexes and cells of each edge
    %   cells: lists the vertexes and edges of each cell
    % We would also like:
    %   vxs: lists the edges and cells of each vertex.
    
    edgedata = m.secondlayer.edges(eis,:);
    for i=1:length(eis)
        % ei = eis(i);
        v1 = edgedata(i,1);
        v2 = edgedata(i,2);
        c1 = edgedata(i,3);
        c2 = edgedata(i,4);
        % Update the cells.
        nv = length( m.secondlayer.cells(c1).vxs );
        cvi = find( m.secondlayer.cells(c1).vxs==v2, 1 );
        cei = cvi-1;
        cei_atend = cei==0;
        if cei_atend, cei = nv; end
        A0 = m.secondlayer.cell3dcoords( v1, : );
        A1 = m.secondlayer.cell3dcoords( m.secondlayer.cells(c1).vxs(cei), : );
        A2 = m.secondlayer.cell3dcoords( m.secondlayer.cells(c1).vxs(1+mod(cvi,nv)), : );
        e11 = m.secondlayer.cells(c1).edges(cvi);
        v2i = m.secondlayer.edges(e11,[1 2])==v2;
        m.secondlayer.edges(e11,v2i) = v1;
        m.secondlayer.cells(c1).vxs(cvi) = [];
        m.secondlayer.cells(c1).edges(cei) = [];
        if cei_atend
            m.secondlayer.cells(c1).edges = m.secondlayer.cells(c1).edges( [2:end 1] );
        end
        
        nv = length( m.secondlayer.cells(c2).vxs );
        cvi = find( m.secondlayer.cells(c2).vxs==v1, 1 );
        cei = cvi-1;
        cei_atend = cei==0;
        if cei_atend, cei = nv; end
        nv = length( m.secondlayer.cells(c2).vxs );
        B0 = m.secondlayer.cell3dcoords( v2, : );
        B1 = m.secondlayer.cell3dcoords( m.secondlayer.cells(c2).vxs(cei), : );
        B2 = m.secondlayer.cell3dcoords( m.secondlayer.cells(c2).vxs(1+mod(cvi,nv)), : );
        e21 = m.secondlayer.cells(c2).edges(cvi);
        v1i = m.secondlayer.edges(e21,[1 2])==v1;
        m.secondlayer.edges(e21,v1i) = v2;
        m.secondlayer.cells(c2).vxs(cvi) = [];
        m.secondlayer.cells(c2).edges(cei) = [];
        if cei_atend
            m.secondlayer.cells(c2).edges = m.secondlayer.cells(c2).edges( [2:end 1] );
        end
        
        MID = (A0+B0)/2;
        K = 0.5;
        OFF = (A1+A2-B1-B2)*(K/4);
        A = MID+OFF;
        B = MID-OFF;
        m = setBioVxPos( m, [v1 v2], [A;B] );
    end
        
    % Renumber the edges.
    oldnumedges = size( m.secondlayer.edges, 1 );
    edgerenumbernewtoold = 1:oldnumedges;
    edgerenumbernewtoold(eis) = [];
    edgerenumberoldtonew = zeros(1,oldnumedges);
    edgerenumberoldtonew(edgerenumbernewtoold) = 1:(oldnumedges-length(eis));
    % Update the edge data
    for i=1:length(m.secondlayer.cells)
        newedges = edgerenumberoldtonew( m.secondlayer.cells(i).edges );
        if any( newedges==0 )
            xxxx = 1;
        end
        m.secondlayer.cells(i).edges = newedges;
    end
    m.secondlayer.edges(eis,:) = [];
    m.secondlayer.generation(eis) = [];
    m.secondlayer.edgepropertyindex(eis) = [];
    m.secondlayer.interiorborder(eis) = [];
end

function eis = validends( m, eis )
% For each edge index in eis, see if its ends both border air spaces.
    spaceedges = m.secondlayer.edges(:,4) == -1 ;
    spacevxs = sort( reshape( m.secondlayer.edges( spaceedges, [1 2] ), [], 1 ) );
    y = countreps(sort(spacevxs(:)));
    validverts = y( y(:,2)==2, 1 );
    validvertmap = false( length( m.secondlayer.vxFEMcell ), 1 );
    validvertmap( validverts ) = true;
    if length(eis)==1
        % Idiot Matlab!
        eis = eis( all( validvertmap( m.secondlayer.edges(eis,[1 2]) ) ) );
    else
        eis = eis( all( validvertmap( m.secondlayer.edges(eis,[1 2]) ), 2 ) );
    end
end

function vxdata = biovertexdata( m )
    ne = size(m.secondlayer.edges,1);
    alledgedata = sort( [ [m.secondlayer.edges(:,[1 3 4]), (1:ne)'];
                          [m.secondlayer.edges(:,[2 4 3]), (1:ne)'] ], 1 );
    % The rows of alledgedata have the form [v c1 c2 e], where v is a
    % vertex at one end of edge e. and c1 and c2 are the cells on either
    % side.  Either c1 or c2 may be zero, if there is no cell there.  The
    % rows are listed in increasing order of vertex number.
    % If m.secondlayer.edges has consistent ordering, so does this array.
    
    steps = find( alledgedata(1:(end-1),1) ~= alledgedata(2:end,1) );
    ends = [ steps; ne ];
    starts = [ 1; steps+1 ];
    validedge = true( ne, 1 );
    for i=1:length(steps)
        vidata = alledgedata( starts(i):ends(i), 2:end );
        % Each row of vidata consists of [c1 c2 e] where vi is one end of
        % edge e, and c1 and c2 are the cells on either side of e. Either
        % c1 or c2 might be zero.
        numzeros = sum( reshape( vidata( :, [1 2] )==0, [], 1 ) );
        if numzeros ~= 2
            validedge( alledgedata( alledgedata( starts(i):ends(i), 1 ), 4 ) ) = false;
        end
    end
    alledgedata = alledgedata( validedge, : );
end
