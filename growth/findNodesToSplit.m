function [ns,c1s,bc1s,c2s,bc2s,e1s,e2s] = findNodesToSplit( m )
%[ns,c1s,bc1s,c2s,bc2s,e1s,e2s] = findNodesToSplit( m )
%   Find nodes of the mesh that require splitting.
%   If no nodes are selected, n will be empty and the other outputs should
%   be ignored.

    ns = [];
    c1s = [];
    bc1s = [];
    c2s = [];
    bc2s = [];
    e1s = [];
    e2s = [];
    EIG_THRESHOLD = 0.5;
    
    numnodes = size(m.nodes,1);
    numsplits= 0;
    for vi=1:numnodes
        % Find the node normal, as the average of the cell normals of
        % neighbouring cells.
        nce = m.nodecelledges{vi};
        nc = nce(2,:);
        bn = nc(length(nc))==0;
        if bn
            nc = nc(1:(length(nc)-1));
        end
        nodenormal = sum(m.unitcellnormals(nc,:),1)/length(nc);
        nodebasis = makebasis( nodenormal );
        
        % Find the edge vectors, projected into the plane perpendicular to
        % the node normal, and normalised to unit length.
        ne = nce(1,:);
        nbs = m.edgeends(ne,:)';
        nbs = reshape( nbs(nbs ~= vi), [], 1 );
        edgevec = zeros( length(nbs), 3 );
        for nbi = 1:length(nbs)
            v = m.nodes(nbs(nbi),:) - m.nodes(vi,:);
            v = makeperp( nodenormal, v );
            edgevec(nbi,:) = normaliseVector( v );
        end
        
        % Determine the edge vectors in the tangent frame.
        edgevectan = edgevec*nodebasis(:,[2 3]);
        
        % If the node is on the border of the mesh, weight the border edge
        % vectors by half.
        if nce(2,size(nce,2))==0
            edgevectan(1,:) = edgevectan(1,:)/2;
            nevt = size(edgevectan,1);
            edgevectan(nevt,:) = edgevectan(nevt,:)/2;
        end
        
        % Determine the shape tensor of the edge vectors, its eigenvalues,
        % and their ratio.
        t = neighbourhoodTension( edgevectan );
        [v,d] = eig(t);
        eigratio = d(1,1)/d(2,2);
        
        % Determine whether to split the node or not.
        if eigratio < EIG_THRESHOLD
            % Yes.
            fprintf( 1, 'Eigratio %d %f < %f.\n', vi, eigratio, EIG_THRESHOLD );
            numsplits = numsplits+1;
            splits{numsplits} = struct( ...
                'eigratio', eigratio, ...
                'vi', vi, ...
                'edgevectan', edgevectan, ...
                'eigvecs', v, ...
                'bordernode', bn, ...
                'nodebasis', nodebasis );
            % Need to consider the edge angles as well.  Don't split if
            % there are no small angles, regardless of the shape tensor.
        end
    end
    clear eigratio vi edgevectan v bn nodebasis nce ne nc nbs
    
    if numsplits==0
        return;
    end
    
    definiteSplits = 0;
    % Now calculate the information required for splitting.
    for si = 1:numsplits
        s = splits{si};
        vi = s.vi;
        nce = m.nodecelledges{vi};
        nc = nce(2,:);
        ne = nce(1,:);
        
        % Find the directions of the major eigenvector and all the edges.
        mainaxis = s.eigvecs(:,2)';

        % When the node is on the border, we want to split either along the
        % border or perpendicular to it.  Change mainaxis accordingly.
        if s.bordernode
            borderdir = normaliseVector(s.edgevectan(1,:) - s.edgevectan(length(ne),:));
            borderperp = makeperp( mainaxis, borderdir );
            splitborderperp = dot(borderdir,mainaxis) < sqrt(0.5);
            
            % MORE TO BE DONE
        else
            % The mainaxis and its opposite lie between consecutive pairs 
            % of edges.  Find both these pairs.  Except when the node lies
            % on the border of the mesh, in which case we must split either
            % along the border or perpendicular to it.
            s
            axisperp = [ mainaxis(2), -mainaxis(1) ];
            d = zeros( 1, size(s.edgevectan,1) );
            perpproj = zeros(size(d));
            for ei=1:size(s.edgevectan,1)
                perpproj(ei) = dot( axisperp, s.edgevectan(ei,:) );
            end
            d = perpproj >= 0;
            es = find( d ~= d( [2:end, 1] ) );
            es = [ es; mod(es,length(d))+1 ]
            nees = ne(es)
            % es is a 2*2 matrix.  Its columns are the required pairs of edges,
            % expressed as indexes into ne.
            c1 = nc(es(1,1))
            c2 = nc(es(1,2))
            [minproj,minpi] = min(perpproj);
            [maxproj,maxpi] = max(perpproj);
            e1 = ne(minpi);
            e2 = ne(maxpi);
            % e1 and e2 are the edges which will be duplicated.

            % Find which vertex vi is of c1 and c2.
            c1vi = find(m.tricellvxs(c1,:)==vi);
            if c2==0
                c2vi = 0;
            else
                c2vi = find(m.tricellvxs(c2,:)==vi);
            end
            if isempty(c1vi)
                fprintf( 1, '%s: Expected %d to be a vertex of %d, but vertexes are [%d %d %d].\n', ...
                    mfilename(), vi, c1, m.tricellvxs(c1,:) );
                return;
            end
            if isempty(c2vi)
                fprintf( 1, '%s: Expected %d to be a vertex of %d, but vertexes are [%d %d %d].\n', ...
                    mfilename(), vi, c2, m.tricellvxs(c2,:) );
                return;
            end

            % Find the barycentric coordinates of the intersection of the
            % mainaxis
            % with the lines joining the midpoints of the pairs of edges.
            % Or maybe we should just take the point [ 1/2, 1/4, 1/4 ]?
            % If the node is on the border of the mesh, we should take edge
            % barycentric coordinates of [2/3 1/3].
            % TO BE DONE

            % Find the best edges to split.  Border edges are special again.
            % TO BE DONE

            % Add all this information to the [ns,c1s,bc1s,c2s,bc2s,e1s,e2s]
            % structure that we are returning.
            definiteSplits = definiteSplits+1;
            ns(definiteSplits) = vi;
            c1s(definiteSplits) = c1;
            bc1s(definiteSplits,:) = [0,0,0];  % Not calculated yet.
            c2s(definiteSplits) = c2;
            bc2s(definiteSplits,:) = [0,0,0];  % Not calculated yet.
            e1s(definiteSplits) = e1;
            e2s(definiteSplits) = e2;
            % TO BE DONE
        end
    end
    
    return;

    % For each node, find the cell incident on that node having the
    % smallest angle there.
    numnodes = size(m.nodes,1);
    minangs = ones(numnodes,1) * -1;
    cis = zeros(numnodes,1);
    for vi=1:numnodes
        ce = m.nodecelledges{vi};
        edges = ce(1,:);
        numedges = length(edges);
        nbs = otherend( m, vi, edges );
        % Set edgevecs to the set of vectors from n to each of its
        % neighbours.
        edgevecs = zeros(numedges,3);
        for ei=1:numedges
            edgevecs(ei,:) = m.nodes(nbs(ei),:) - m.nodes(vi,:);
        end
        % va is the set of angles between consecutive edges.
        va = zeros(numedges,1);
        for ei=1:numedges
            va(ei) = vecangle( edgevecs(ei,:), edgevecs(mod(ei,numedges)+1,:) );
        end
        [minangs(vi),cis(vi)] = min(va);
    end
    
    % Set nbarray so that nbarray(i,j) is zero if and only if nodes i and
    % j are not neighbours and have no neighbour in common.
    nbarray = sparse(numnodes,numnodes);
    for ei=1:size(m.edgeends,1)
        nbarray(m.edgeends(ei,1),m.edgeends(ei,2)) = 1;
        nbarray(m.edgeends(ei,2),m.edgeends(ei,1)) = 1;
    end
    nbarray = nbarray*nbarray;

    % Find all nodes with an incident angle below the threshold.
    % Then step through all of these nodes, rejecting any node that is a
    % neighbour of or has a neighbour in common with any earlier node.
    badnodes = [];
    for vi=find( minangs' < ang )
        neighbouring = false;
        for vj=1:length(badnodes)
            if nbarray( vi, badnodes(vj) ) > 0
              % fprintf( 1, '%d neighbours %d, %d omitted.\n', ...
              %     vi, badnodes(vj), vi );
                neighbouring = true;
                break;
            else
              % fprintf( 1, 'nba(%d,%d) = %d\n', ...
              %     vi, badnodes(vj), nbarray( vi, badnodes(vj) ) );
            end
        end
        if ~neighbouring
            badnodes = [ badnodes, vi ];
        end
    end
    
    % Allocate space for the final results.
    numbadnodes = length(badnodes);
    ns = badnodes;
    c1s = zeros(numbadnodes,1);
    bc1s = zeros(numbadnodes,3);
    c2s = zeros(numbadnodes,1);
    bc2s = zeros(numbadnodes,3);
    e1s = zeros(numbadnodes,1);
    e2s = zeros(numbadnodes,1);
    
    for bni=1:numbadnodes
        ni = badnodes(bni);
        nci = cis(ni);
        nce = m.nodecelledges{ni};
        nc = nce(2,:);
        ne = nce(1,:);
        
        % Now we need to find the cell containing the direction opposite to
        % the selected direction.
        e11 = ne(nci);
        e12 = ne(mod(nci,length(ce))+1);
        n11 = otherend( m, e11, ni );
        n12 = otherend( m, e12, ni );
        % d1 is opposite to the direction of the first new node.
        d1 = m.nodes(ni,:) - m.nodes(n11,:) - m.nodes(n12,:);

        % Test whether ni is a border node.
        if nc(length(nc))==0
            % If ni is a border node, then we should split either along the
            % border or perpendicularly to the border, depending on which
            % direction is closest to d1.
            firstedge = ne(1);
            lastedge = ne(length(ne));
            edgenode1 = otherend( m, ni, lastedge );
            edgenode2 = otherend( m, ni, firstedge );
            edgevec1 = m.nodes(edgenode1,:) - m.nodes(ni,:);
            edgevec2 = m.nodes(edgenode2,:) - m.nodes(ni,:);
            a1 = vecangle( edgevec1, d1 );
            if a1 > pi/2, a1 = pi/2-a1; end
            a2 = vecangle( edgevec2, d1 );
            if a2 > pi/2, a2 = pi/2-a2; end
            if (a1 < pi/4) || (a2 < pi/4)
                % Split parallel to the border.
                fprintf( 1, 'findNodeSToSplit: parallel to border.\n' );
                c1s(i) = nc(length(nc)-1);
                bc1s(i,m.tricellvxs(c1(i),:)==ni) = 2/3
                bc1s(i,m.tricellvxs(c1(i),:)==edgenode1) = 1/3
                c2s(i) = nc(1);
                bc2s(i,m.tricellvxs(c2(i),:)==ni) = 2/3;
                bc2s(i,m.tricellvxs(c2(i),:)==edgenode2) = 1/3;
                e1s(i) = ne( int32((1+length(ne))/2) );
                e2s(i) = 0;
            else
                % Split perpendicular to the border.
                fprintf( 1, 'findNodesToSplit: perpendicular to border -- not implemented.\n' );
                
            end
        else
            % For an interior node,
            % compute the angle bisectors of all the triangles incident on n.
            % Find the bisector that bears the smallest angle to d1.
            % The cell containing this median is c2.
            c1s(i) = nc(nci);
            bc1s(i,:) = [1/6 1/6 1/6];
            bc1s( i, m.tricellvxs(c1(i),:)==ni ) = 2/3;
            numedges = length(ne);
            nbs = otherend( m, ni, ne );
            edgevecs = zeros(numedges,3);
            for ei=1:numedges
                v = m.nodes(nbs(ei),:) - m.nodes(ni,:);
                edgevecs(ei,:) = v/norm(v);
            end
            a = ones(numedges,1) * -1;
            for ei=1:numedges
                median = (edgevecs(ei,:) + edgevecs(mod(ei,numedges)+1,:))/2;
                a(ei) = vecangle( median, d1 );
            end
            [amin,ai] = min(a);
            if (0 <= amin) && (amin < pi/2)
                c2s(i) = nc(ai);
                if c2s(i)
                    bc2s(i,:) = [1/6 1/6 1/6];
                    bc2s( i, m.tricellvxs(c2(i),:)==ni ) = 2/3;
                end
            end

            % Now we need to find the edges to split.  One of these is the edge
            % that is as nearly perpendicular to d1 as possible.  The other is
            % the edge as nearly opposite as possible to the first edge.
            perpa = min( a, pi-a );
            [perpmax,perpmaxi] = max(perpa);
            e1i = ne(perpmaxi);
            for ei=1:numedges
                a(ei) = dot( edgevecs(perpmaxi,:), edgevecs(ei,:) );
            end
            [oppness,oppi] = min(a);
            e2i = ne(oppi);

            % Need to get e1i and e2i the right way round.  e1i should be
            % anticlockwise from d1.  To find the ordering, we map c1, e1i, an
            % de2i back into the cell/edge list
            ce_nci = nci*2;
            ce_e2i = e2i*2-1;
            ce_e1i = e1i*2-1;
            if positiveCycle( ce_nci, ce_e2i, ce_e1i )
                e1s(i) = e1i;
                e2s(i) = e2i;
            else
                e1s(i) = e2i;
                e2s(i) = e1i;
            end
        end
    end
end

function ok = positiveCycle( a, b, c )
%ok = positiveCycle( a, b, c )
%   Returns true if, counting upwards from A mod max(A,B,C), one first
%   encounters B, then C.
    if a > b
        ok = (b <= c) && (c <= a);
    else
        ok = (b <= c) || (c <= a);
    end
end
