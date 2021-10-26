function [ns,fs,amt] = voronoiChange( v, dv, smalledge )
%voronoiChange( v, dv )
%   V is a set of voronoi generating points.
%   DV is a perturbation to V.
%   We compute the change in edge lengths of the Voronoi tessellation of V
%   when DV is added to V, on the assumption that the topology of the
%   network does not change.  Since smalledges tend to be fragile, we
%   ignore edges whose length is less than 0.2 of the typical cell
%   diameter.
%
%   Several measures of edge shrinkage are returned:
%       NS: the number of edges, originally above the threshold length,
%       which shrank.
%       FS: the fraction of edges, originally above the threshold length,
%       which shrank.
%       AMT: geometric mean of the shrinkage, taking non-shrinking edges to
%       have zero shrinkage.

    t = delaunay( v(:,1), v(:,2) );
    e = edgemap( t );
    ne = size(e,1);

    vv0 = voronoiFromDelaunay( v, t );
    e0 = edgelengths( e, vv0 );

    v = v+dv;
    vv1 = voronoiFromDelaunay( v, t );
    e1 = edgelengths( e, vv1 );
    
    cellsize = sqrt(prod(max(v,[],1) - min(v,[],1))/size(v,1));
    badedges = find((e0 > cellsize*smalledge) & (e1 < e0));
    ns = length(badedges);
    fs = ns/ne;
    e0 = e0(badedges);
    e1 = e1(badedges);
    % e0(badedges)'/cellsize
  % sprintf( '%d/%d bad edges', ns, ne )
  % [e0 e1]
  % e1./e0
    if isempty(e0)
        amt = 0;
    else
        amt = fs * (exp( sum(log( e1 ./ e0 ))/length(e0) ) - 1);
    end
end

function e = edgemap( t )
    nt = size(t,1);
    emap = zeros( nt );
    for i=1:nt-1
        for j=i+1:nt
            if length(unique( [ t(i,:) t(j,:) ] ) )==4
                emap(i,j) = 1;
            end
        end
    end
    [ei,ej] = find(emap);
    e = [ei,ej];
end

function el = edgelengths( e, vv )
    el = zeros(size(e,1),1);
    for i=1:size(e,1)
        el(i) = norm(vv(e(i,1),:) - vv(e(i,2),:));
    end
end
