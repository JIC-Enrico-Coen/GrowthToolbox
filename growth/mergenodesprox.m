function [newvxs,remap] = mergenodesprox( vxs, tol, transitive )
%[newvxs,remapnodes] = mergenodesprox( vxs, tol, transitive )
%   vxs is an N*D array of N D-dimensional vectors. This procedure merges
%   vertexes that lie within a distance TOL of each other along each axis.
%   When a cluster of vertexes is merged, the new vertex is at the centre
%   of their bounding box.
%
%   If TRANSITIVE is true, then whenever a vertex X is close to Y, and Y is
%   close to Z, then X is deemed close to Z, even if X and Z are farther
%   apart than TOL. Thus all vertexes close to each other are merged, but
%   some vertexes far from each other may also be merged. The set of
%   resulting vertexes will be independent of the order of the given
%   vertexes.
%
%   If TRANSITIVE is false, vertexes far from each other are never
%   merged, but some vertexes that are close to each other may not be
%   merged. The number and positions of the resulting vertexes may depend
%   on the order of the given vertexes.
%
%   By default, TRANSITIVE is false. 
%
%   REMAP maps the index of each vertex of VXS to that of its
%   representative in NEWVXS.

    if nargin < 3
        transitive = false;
    end
    numvxs = size(vxs,1);
    numdims = size(vxs,2);
    prox = [];
    for i=1:numdims
        [xx,xxp] = sort( vxs(:,i) );
        
        if transitive
            dxx = xx(2:end) - xx(1:(end-1));
            xxclose = find( [dxx <= tol; false] );
            xxclosepairs = [ xxclose, xxclose+1 ];
            xxclosepairs = xxp(xxclosepairs);
            xxprox = false( numvxs, numvxs );
            xxprox( sub2ind( [numvxs numvxs], xxclosepairs(:,1), xxclosepairs(:,2) ) ) = true;
            xxprox = transitiveClosure(xxprox);
        else
            if tol > 0
                nb = (xx(end)-xx(1))/tol;
                d = (nb - floor(nb))/2;
                if d < 0.25
                    d = 0.5-d;
                end
                xxclass = ceil(xx/tol + d);
            else
                xxclass = xx(2:end)==xx(1:(end-1));
            end
            [starts,ends] = runends( xxclass );
            xxprox = false( numvxs, numvxs );
            for j=1:length(starts)
                range = xxp(starts(j):ends(j));
                xxprox( range, range ) = true;
            end
        end
        if isempty(prox)
            prox = xxprox;
        else
            prox = prox & xxprox;
        end
    end
    [~,~,remap] = unique( prox, 'rows' );
    [newindexing,perm] = sort( remap );
    [starts,ends] = runends( newindexing );
    numgroups = length( starts );
    newvxs = zeros( numgroups, numdims );
    for i=1:numgroups
        range = starts(i):ends(i);
        rangelength = length(range);
        if rangelength == 1
            newvxs(i,:) = vxs(perm(range),:);
        else
%             newvxs(i,:) = sum( vxs( perm(range), : ), 1 )/rangelength;  % Average
            newvxs(i,:) = (max( vxs( perm(range), : ), [], 1 ) + min( vxs( perm(range), : ), [], 1 ))/2; % Centre of bounding box.
        end
    end
    
    PLOTTING = false;
    if PLOTTING
        figure(1);
        plotpts( vxs,'ob');
        hold on;plotpts( newvxs + 0.01*ones(size(newvxs)),'or');hold off
    %     axis([0 1 0 1]);
        axis equal;
    end
end
