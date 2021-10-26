function [bn,ba,be] = componentBoundary( m, vi )
%[bn,ba] = componentBoundary( m, vi )
%   Given a mesh m and a vertex vi, assumed to be a boundary vertex, set bn
%   to the sequence of vertexes around the boundary starting from v.  Set ba to
%   the external angles at those vertexes, i.e. pi minus the sum of the internal
%   angles of the triangles at each vertex.  Set be to the lengths of the
%   edges.

    bn = zeros(1,0);
    ba = zeros(1,0);
    cellangles = femCellAngles( m );
    startVertex = vi;
    numvxs = 0;
    while true
        nce = m.nodecelledges{vi};
        numnbcells = size(nce,2)-1;
        ang = 0;
        for i=1:numnbcells
            ci = nce(2,i);
            ciei = find( m.tricellvxs(ci,:)==vi );
            ang = ang + cellangles(ci,ciei);
        end
        numvxs = numvxs+1;
        bn(numvxs) = vi;
        ba(numvxs) = pi - ang;
        vj = nextBoundaryVertex( m, nce, vi );
        be(numvxs) = norm( m.nodes(vi,:) - m.nodes(vj,:) );
        if vj == startVertex
            break;
        end
        vi = vj;
    end
end

function vj = nextBoundaryVertex( m, nce, vi )
    ei = nce(1,1);
    ends = m.edgeends(ei,:);
    vj = ends(ends ~= vi);
end
