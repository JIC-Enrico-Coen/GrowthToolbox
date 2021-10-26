function vError = checkVoronoiAngles( V, P )
%checkVoronoiAngles( V, P )
%   [V,P] is the output of VORONOIN(...): V is the set of vertexes of the
%   Voronoi network, and P the set of vertex lists that define the cells.
%   For every vertex in V, if there are N edges meeting at the vertex,
%   where N >= 3, then the angles between them should be 2pi/N.  Calculate
%   the average deviation from that figure over the whole network.  This
%   can be used as a measure of non-centroidality of the network.
%   When the CVT algorithm is run, it typically converges from an initial
%   error value of about 0.5 for a random set of Voronoi generators to
%   about 0.2, that is, from about 30 degrees to about 12 degrees.
%
%   If P is not given, V is assumed to be a set of Voronoi generators, and
%   the Voronoi network is first calculated from them.

    if nargin < 2
        [V,P] = voronoin(V);
    end

    vcount = zeros(size(V,1));
    edges = cell(1,size(V,1));
    polys = cell(1,size(V,1));
    for i=1:length(P)
        vcount(P{i}) = vcount(P{i}) + 1;
        for j=1:length(P{i})
            v = P{i}(j);
            if all(isfinite(V(v,:)))
                polys{v}( length(polys{v})+1 ) = i;
                j1 = j+1;  if j1 > length(P{i}), j1 = 1; end
                j2 = j-1; if j2 <= 0, j2 = length(P{i}); end
                edges{v}( length(edges{v})+1 ) = P{i}(j1);
                edges{v}( length(edges{v})+1 ) = P{i}(j2);
            end
        end
    end

    totdisperror = 0;
    numdisperror= 0;
    for i=1:size(V,1)
        if all(isfinite(V(i,:))) && all(all(isfinite(V(edges{i},:))))
            edges{i} = unique( edges{i} );
            numnbs = length(edges{i});
            if numnbs > 2
                angles = zeros( 1, numnbs );
                totdisp = [0 0];
                for j=1:numnbs
                    delta = V(edges{i}(j),:) - V(i,:);
                    angles(j) = atan2( delta(2), delta(1) );
                    ldelta = norm(delta);
                    if ldelta > 0
                        totdisp = totdisp + delta/norm(delta);
                    end
                end
                totdisperror = totdisperror + norm(totdisp);
                numdisperror = numdisperror+1;
            end
        end
    end
    
    if numdisperror==0
        vError = 0;
    else
        vError = totdisperror/numdisperror;
    end
end
