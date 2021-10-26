function [bn,ba,be] = componentBoundary2( m, vi )
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
    vns = zeros( 1, 0 );
    while true
        bn(numvxs) = vi;
        
        nce = m.nodecelledges{vi};
        vns(i,:) = vertexNormal( m, nce )
        numnbcells = size(nce,2)-1;
        ang = 0;
        for i=1:numnbcells
            ci = nce(2,i);
            ciei = find( m.tricellvxs(ci,:)==vi );
            ang = ang + cellangles(ci,ciei);
        end
        numvxs = numvxs+1;
        ba(numvxs) = pi - ang;
        
        vj = nextBoundaryVertex( m, nce, vi );
        be(numvxs) = norm( m.nodes(vi,:) - m.nodes(vj,:) );
        
        if vj == startVertex
            break;
        end
        vi = vj;
    end
    
    
    vns; % vertex normals
    evs = m.nodes( bn( [2:end,1], : ) - m.nodes( bn, : );
    evs1 = projectToPlane( vns, evs );
    evs2 = projectToPlane( vns, evs( [end, 1:(end-1)], : );
    ba = vecangle( evs1, evs2, vns );
end

function vecs = projectToPlane( ns, vecs )
%vecs = projectToPlane( ns, vecs )
%   Project the vectors that are the rows of vecs into the plane
%   perpendicular to the unit vectors ns.
    dots = sum( vecs.*ns, 2 );
    vecs = vecs - repmat(dots,1,3).*ns;
end

function n = vertexNormal( m, nce )
%n = vertexNormal( m, nce )
%   Calculate the normal to the mesh at the vertex whose nodecelledges
%   array is nce, by averaging the normals of the cells that vi belongs to.

    cis = nce(2,end-1);
    cns = m.cellnormals( cis, : );
    invcas = 1./m.cellareas( cns );
    n = sum( cns.*repmat(invcas,1,3), 1 )/sum(invcas);
    n = n/norm(n);
end

function vj = nextBoundaryVertex( m, nce, vi )
    ei = nce(1,1);
    ends = m.edgeends(ei,:);
    vj = ends(ends ~= vi);
end
