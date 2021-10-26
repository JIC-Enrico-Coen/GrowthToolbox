function [ok,m] = checkConnectivityOldMesh( m, verbose )
%ok = checkConnectivityOldMesh( m )
%   Perform validity checks on the connectivity information for a mesh of
%   one layer of pentahedra.

    ERRORS = false;
    if ERRORS
        complainer = @error;
    else
        complainer = @warning;
    end
    if verbose
        whiner = @warning;
    else
        whiner = @donothing;
    end

    ok = true;

    numnodes = size( m.nodes, 1 );
    numedges = size(m.edgeends,1);
    numelements = size( m.tricellvxs, 1 );

% Check that every triangle has three distinct vertexes.
for fi=1:numelements
    vxs = m.tricellvxs(fi,:);
    if (vxs(1)==vxs(2)) || (vxs(3)==vxs(1)) || (vxs(2)==vxs(3))
        ok = false;
        complainer( 'Triangle %d fails to have distinct vertexes: [%d,%d,%d].\n', ...
            fi, vxs(1), vxs(2), vxs(3) );
    end
end

% Check that every triangle has three distinct edges.
for fi=1:numelements
    es = m.celledges(fi,:);
    if (es(1)==es(2)) || (es(3)==es(1)) || (es(2)==es(3))
        ok = false;
        complainer( 'Triangle %d fails to have distinct edges: [%d,%d,%d].\n', ...
            fi, es(1), es(2), es(3) );
    end
end

% Check that for every connection from a cell to an edge in celledges,
% the edge index is valid, and there is a connection from that edge to that
% cell in edgecells.
% if any( all( m.celledges ~= repmat((1:nf)',1,3), 2 ), 1 )
    for fi=1:numelements
        for ei=m.celledges(fi,:)
            if all(m.edgecells(ei,:) ~= fi)
                ok = false;
                complainer( 'validmesh:celledge2', ...
                    'Cell %d has edge %d but edge is connected to cells %d and %d.', ...
                    fi, ei, m.edgecells(ei,1), m.edgecells(ei,2) );
            end
        end
    end
% end
if any(any((m.celledges<1) | (m.celledges > numedges)))
    for fi=1:numelements
        eis = m.celledges(fi,:);
        for ei=eis
            if (ei < 1) || (ei > numedges)
                ok = false;
                complainer( 'validmesh:celledge1', ...
                    'Cell %d has edge %d, which is outside the valid range %d:%d.', ...
                    fi, ei, 1, numedges );
            end
        end
    end
end

% Check that the ends of each edge and the cells on either side of the
% edge, as given by edgeends and edgecells, are valid indexes.
% Check that the ends of each edge are vertexes of the cells of that edge.
% Check that the edge ends are distinct.
% Check that every edge has a cell on at least one side.
% Check that if there is a cell on both sides of the edge, the two cells
% are distinct.
if any(any(m.edgeends<1))
    ok = false;
    for ei=1:numedges
        p1 = m.edgeends(ei,1);
        if p1 < 1
            complainer( 'validmesh:badpointindex1', ...
                'Edge %d endpoint 1 is %d, should be positive.', ...
                ei, p1 );
        end
        p2 = m.edgeends(ei,2);
        if p2 < 1
            complainer( 'validmesh:badpointindex2', ...
                'Edge %d endpoint 2 is %d, should be positive.', ...
                ei, p2 );
        end
    end
end
sameends = m.edgeends(:,1)==m.edgeends(:,2);
if any(sameends)
    ok = false;
    for ei=1:numedges
        if sameends(ei)
            complainer( 'validmesh:badpointindex3', ...
                'Edge %d endpoints should be distinct, are %d %d', ...
                ei, m.edgeends(ei,1), m.edgeends(ei,2) );
        end
    end
end
if any(any(m.edgeends>numnodes))
    ok = false;
    for ei=1:numedges
        p1 = m.edgeends(ei,1);
        if p1 > numnodes
            complainer( 'validmesh:badpointindex1', ...
                'Edge %d endpoint 1 is %d, should be not more than %d.', ...
                ei, p1, numnodes );
        end
        p2 = m.edgeends(ei,2);
        if p2 > numnodes
            complainer( 'validmesh:badpointindex2', ...
                'Edge %d endpoint 2 is %d, should be not more than %d.', ...
                ei, p2, numnodes );
        end
    end
end
badcells = m.edgecells(:,1) < 1;
if any(badcells)
    ok = false;
    for ei=find(badcells)'
        complainer( 'validmesh:badpointindex4', ...
            'Edge %d cell 1 is %d, should be positive.', ...
            ei, m.edgecells(ei,1) );
    end
end
badcells = m.edgecells(:,1) < 0;
if any(badcells)
    for ei=find(badcells)'
        ok = false;
        complainer( 'validmesh:badpointindex4', ...
            'Edge %d cell 2 is %d, should be non-negative.', ...
            ei, m.edgecells(ei,2) );
    end
end
badcells = m.edgecells > numelements;
if any(badcells(:))
    ok = false;
    for ei=1:numelements
        for j=1:2
            complainer( 'validmesh:badpointindex4', ...
                'Edge %d cell %d is %d, should be no more than %d.', ...
                ei, j, m.edgecells(ei,j), numelements );
        end
    end
end
badcells = m.edgecells(:,1)==m.edgecells(:,2);
if any(badcells(:))
    ok = false;
    for ei=find(badcells)'
        complainer( 'validmesh:badpointindex6', ...
            'Edge %d cells on either side should be distinct, are %d %d', ...
            ei, m.edgecells(ei,1), m.edgecells(ei,2) );
    end
end
for ei=1:numedges
    f1 = m.edgecells(ei,1);
    f2 = m.edgecells(ei,2);
    if (f1 ~= 0) && ~isedgeof( m, ei, f1 )
        ok = false;
        complainer( 'validmesh:badpointindex7', ...
            'Edge %d (n %d,%d) (f %d,%d) is not an edge or not the right edge of cell %d (p %d,%d,%d, e %d,%d,%d)', ...
            ei, m.edgeends(ei,1), m.edgeends(ei,2), ...
            f1, f2, f1, ...
            m.tricellvxs(f1,1), m.tricellvxs(f1,2), m.tricellvxs(f1,3), ...
            m.celledges(f1,1), m.celledges(f1,2), m.celledges(f1,3) );
    end
    if (f2 ~= 0) && ~isedgeof( m, ei, f2 )
        ok = false;
        complainer( 'validmesh:badpointindex8', ...
            'Edge %d (n %d,%d) (f %d,%d) is not an edge or not the right edge of cell %d (p %d,%d,%d, e %d,%d,%d)', ...
            ei, m.edgeends(ei,1), m.edgeends(ei,2), f1, f2, f2, ...
            m.tricellvxs(f2,1), m.tricellvxs(f2,2), m.tricellvxs(f2,3), ...
            m.celledges(f2,1), m.celledges(f2,2), m.celledges(f2,3) );
    end
end

% Check that two cells do not have the same vertexes.
    errs = checkUniqueRows( m.tricellvxs );
    if ~isempty(errs)
        ok = false;
        complainer( 'validmesh:dupcellvxs', ...
            'Some cells have the same vertexes:' );
        fprintf( 1, ' %d', errs );
        fprintf( 1, '\n' );
    end
% Check that two cells do not have the same edges.
    errs = checkUniqueRows( m.celledges );
    if ~isempty(errs)
        ok = false;
        complainer( 'validmesh:dupcelledges', ...
            'Some cells have the same edges:' );
        fprintf( 1, ' %d', errs );
        fprintf( 1, '\n' );
    end
% Check that two edges do not have the same ends.
    errs = checkUniqueRows( m.edgeends );
    if ~isempty(errs)
        ok = false;
        complainer( 'validmesh:dupedgeends', ...
            'Some edges have the same ends:' );
        fprintf( 1, ' %d', errs );
        fprintf( 1, '\n' );
    end

% Check that the mesh is oriented.
% This means that every edge that belongs to two cells should have its ends
% occur in opposite orders in those cells.
checkOrientation = 1;
if checkOrientation
    for ei=1:numedges
        c2 = m.edgecells(ei,2);
        if c2==0, continue; end
        c1 = m.edgecells(ei,1);
        n1 = m.edgeends(ei,1);
        n2 = m.edgeends(ei,2);
        c1n1 = find(m.tricellvxs(c1,:)==n1);
        c1n2 = find(m.tricellvxs(c1,:)==n2);
        c2n1 = find(m.tricellvxs(c2,:)==n1);
        c2n2 = find(m.tricellvxs(c2,:)==n2);
        fwd1 = mod(c1n2-c1n1,3)==1;
        fwd2 = mod(c2n2-c2n1,3)==1;
        if fwd1==fwd2
            % Orientation error
            ok = false;
            complainer( 'validmesh:orientation', ...
                'Cells %d [%d %d %d] and %d [%d %d %d] contain edge %d with nodes %d and %d in the same order.\n', ...
                c1, m.tricellvxs(c1,1), m.tricellvxs(c1,2), m.tricellvxs(c1,3), ...
                c2, m.tricellvxs(c2,1), m.tricellvxs(c2,2), m.tricellvxs(c2,3), ...
                ei, n1, n2 );
        end
    end
end

% Check that every node belongs to some cell.
allCellNodes = unique(reshape(m.tricellvxs,1,[]));
checkallints( 'validmesh tricellvxs', allCellNodes, numnodes );
% Check that every edge belongs to some cell.
allCellEdges = unique(reshape(m.celledges,1,[]));
checkallints( 'validmesh celledges', allCellEdges, numedges );
% Check that every node belongs to some edge.
allEdgeEnds = unique(reshape(m.edgeends,1,[]));
checkallints( 'validmesh edgeends', allEdgeEnds, numnodes );
% Check that every cell belongs to some edge.
allEdgeCells = unique(reshape(m.edgecells,1,[]));
if (~isempty(allEdgeCells)) && (allEdgeCells(1)==0)
    allEdgeCells = allEdgeCells(2:end);
end
checkallints( 'validmesh edgecells', allEdgeCells, numelements );

% Check that nodecelledges is valid.
badnodecelledges = false;
if ~isfield( m, 'nodecelledges' )
    badnodecelledges = true;
    whiner( 'validmesh:nodecelledges', ...
        'nodecelledges field is missing.\n' );
else
    if length(m.nodecelledges) ~= size(m.nodes,1)
        badnodecelledges = true;
        whiner( 'validmesh:nodecelledges', ...
            'nodecelledges has the wrong length: %d found, but %d nodes in the mesh.\n', ...
            length(m.nodecelledges), size(m.nodes,1) );
    else
        for vi = 1:length(m.nodecelledges)
            nce = m.nodecelledges{vi};
            if isempty(nce)
                warning( 'validmesh:chains1', ...
                    'Node %d has an empty array of neighbours.', ...
                    vi );
                ok = false;
            else
                nbedges = nce(1,:);
                nbcells = nce(2,:);
                % Check that vi is an end of every edge in nbedges
                badnbedges = find( ~any( m.edgeends( nbedges, : )==vi, 2 ) );
                if any( badnbedges )
                    badnodecelledges = true;
                    whiner( 'validmesh:nodecelledges', ...
                        'node %d is not a neighbour of edges %s which are in its neighbour list %s.\n', ...
                        vi, ...
                        nums2string( nbedges(badnbedges), '%d' ), ...
                        nums2string( nbedges, '%d' ) );
                end
                % Check that vi is an end of every cell in nbcells
                nznbcells = find( nbcells ~= 0 );
                badnbcells = find( ~any( m.tricellvxs( nbcells(nznbcells), : )==vi, 2 ) );
                if any(badnbcells)
                    badnodecelledges = true;
                    whiner( 'validmesh:nodecelledges', ...
                        'node %d is not a vertex of cells %s which are in its neighbour list %s.\n', ...
                        vi, ...
                        nums2string( nbcells(nznbcells(badnbcells)), '%d' ), ...
                        nums2string( nbcells, '%d' ) );
                end
                % Check that the sequence of edges agrees with the sequence
                % of cells.
                ec = m.edgecells(nbedges,:);
                ncec = [ nbcells; nbcells([end 1:(end-1)]) ]';
                for nci=1:length(nbedges)
                    if (~all(ec(nci,:)==ncec(nci,:))) && (~all(ec(nci,:)==ncec(nci,[2 1])))
                        whiner( 'validmesh:nodecelledges', ...
                            'node %d has inconsistent cell/edge numbering at edge %d (%d). Expected cells %d and %d, found %d and %d.\n', ...
                            vi, nci, nbedges(nci), ec(nci,1), ec(nci,2), ncec(nci,1), ncec(nci,2) );
                        badnodecelledges = true;
                    end
                end
            end
        end
    end
end
if badnodecelledges && ok
    m = makeVertexConnections( m );
    complainer( 'validmesh:nodecelledges', ...
        'The nodecelledges structure has been repaired.' );
end

end


function result = isedgeof(m,ei,fi)
%ISEDGEOF(P,E,F,EI,FI)  Test whether edge EI is an edge of cell FI.
    result = 1;
    ep1 = m.edgeends(ei,1);
    ep2 = m.edgeends(ei,2);
    fp1 = m.tricellvxs(fi,1);
    fp2 = m.tricellvxs(fi,2);
    fp3 = m.tricellvxs(fi,3);
    fe1 = m.celledges(fi,1);
    fe2 = m.celledges(fi,2);
    fe3 = m.celledges(fi,3);
    if (fe1==ei)
        if ((ep1~=fp2) || (ep2~=fp3)) && ((ep1~=fp3) || (ep2~=fp2))
            fprintf( 1, 'isedgeof( %d, %d ) fails at fe1\n', ei, fi );
            fprintf( 1, 'ep %d %d fp %d %d %d fe %d %d %d\n', ...
                ep1, ep2, fp1, fp2, fp3, fe1, fe2, fe3 );
            result = 0;
        end
    elseif (fe2==ei)
        if ((ep1~=fp3) || (ep2~=fp1)) && ((ep1~=fp1) || (ep2~=fp3))
            fprintf( 1, 'isedgeof( %d, %d ) fails at fe2\n', ei, fi );
            fprintf( 1, 'ep %d %d fp %d %d %d fe %d %d %d\n', ...
                ep1, ep2, fp1, fp2, fp3, fe1, fe2, fe3 );
            result = 0;
        end
    elseif (fe3==ei)
        if ((ep1~=fp1) || (ep2~=fp2)) && ((ep1~=fp2) || (ep2~=fp1))
            fprintf( 1, 'isedgeof( %d, %d ) fails at fe3\n', ei, fi );
            fprintf( 1, 'ep %d %d fp %d %d %d fe %d %d %d\n', ...
                ep1, ep2, fp1, fp2, fp3, fe1, fe2, fe3 );
            result = 0;
        end
    else
        result = 0;
    end
end

