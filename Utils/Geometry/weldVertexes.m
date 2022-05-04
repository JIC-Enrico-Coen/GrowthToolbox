function g1 = weldVertexes( g, tolerance )
%g = weldVertexes( g, tolerance )
%   Weld together all vertexes of g that lie within a given tolerance of
%   each other in all three coordinates.

    g1 = [];
    
    if nargin < 1
        tolerance = 0;
    end
    
    numvxs = size(g.vxs,1);
    numdims = size(g.vxs,2);
    
    class = zeros( size(g.vxs) );
    for di=1:numdims
        [w,p] = sort( g.vxs(:,di) );
        splits = [ 0; find( w(2:end)-w(1:(end-1)) > tolerance ); numvxs ];
        numsplits = length(splits);
        c = zeros( numvxs, 1 );
        for si=1:(numsplits-1)
            c( (splits(si)+1):splits(si+1), 1 ) = si;
        end
        class(p,di) = c;
    end
    
    [uc,iac,icc] = unique( class, 'rows', 'stable' );
    
    % Make the reduced form of g.vxs, and reindex the polys.
    g1.vxs = g.vxs(iac,:);
    g1.polys = renumberRaggedArray( g.polys, icc, 0 );
    
    % Discard duplicate polys.
    [up,iap,icp] = unique( sort( g1.polys, 2 ), 'rows', 'stable' );
    g1.polys = g1.polys( iap, : );
    
    % Discard polys that contain any vertex repeated.
    p = sort( g1.polys, 2 );
    dupverts = (p(:,1:(end-1))==p(:,2:end)) & (p(:,1:(end-1)) ~= 0);
    g1.polys( any(dupverts,2), : ) = [];
end

function a = renumberRaggedArray( a, i, pad )
    a(a~=pad) = i(a(a~=pad));
end