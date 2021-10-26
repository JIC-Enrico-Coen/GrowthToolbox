function m = forceflat( m )
%m = forceflat( m )
%   Force m to be flat and contained in the XY plane.  The method first
%   chooses a point on the boundary of m.  (If m has no boundary, it isn't
%   flattenable.)  That point is mapped to (0,0,0).  Its neighbour vertexes,
%   in order, are mapped to points (1,y,0) for value of y in the same order.
%   Their neighbours that we haven't seen already are mapped to (2,y,0), and
%   so on until an entire connected component of m has been mapped.  Repeat
%   for every other component, mapping them to the planes z=1, z=2, etc.

    m = setrestsprings( m, true );
    numnodes = size(m.nodes,1);
    nodeindexes = zeros(numnodes,1);
    nodesets = {};
    newnodes = zeros(size(m.nodes));
    for i=1:numnodes
        if (nodeindexes(i)==0) && isboundarynode(m,i)
            curcpt = length(nodesets)+1;
            cpt = [];
            unprocessed = [i];
            stage = 0;
            while ~isempty(unprocessed)
                nu = length(unprocessed);
                newnodes(unprocessed,:) = [ stage*ones(nu,1), (1:nu)'-(nu+1)/2, (curcpt-1)*ones(nu,1) ];
                nodeindexes(unprocessed) = curcpt;
                cpt = [ cpt; unprocessed ];
                nbs = [];
                for j=1:length(unprocessed)
                    n = unprocessed(j);
                    nce = m.nodecelledges{n};
                    ne = nce(1,:);
                    nn = m.edgeends(ne,1);
                    nn2 = m.edgeends(ne,2);
                    nn(nn==n) = nn2(nn==n);
                    if j==1
                        lo = [];
                    else
                        lo = unprocessed(j-1);
                    end
                    if j==length(unprocessed)
                        hi = [];
                    else
                        hi = unprocessed(j+1);
                    end
                    [indexes,values] = segmentOfCircularList( nn, lo, hi );
                    if (~isempty(values)) && (~isempty(nbs)) && (values(1)==nbs(length(nbs)))
                        indexes = indexes(2:length(indexes));
                        values = values(2:length(values));
                    end
                    nbs = [nbs; values(:)];
                end
                if length( unique(nbs) ) < length(nbs)
                    fprintf( 1, '%s: Error: inconsistent neighbour lists.\n', mflename() );
                    return;
                end
                nbs = nbs(nodeindexes(nbs)==0);
                unprocessed = nbs;
                stage = stage+1;
            end
            nodesets{curcpt} = cpt;
        end
    end
    
    m.nodes = newnodes;
    m = forceFlatThickness( m );
end

function isb = isboundarynode(m,i)
    nce = m.nodecelledges{i};
    isb = nce(2,size(nce,2))==0;
end

