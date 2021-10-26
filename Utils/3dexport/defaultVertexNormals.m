function [vxnorm,facevxnorm] = defaultVertexNormals( vxs, facevxs, reduce )
%vxnorm = defaultVertexNormals( vxs, facevxs, reduce )
%   Calculate the vertex normals as the common perpendiculars to
%   consecutive edges.  They will all be unit vectors, except in the case
%   of edges of length zero, which will produce zero "normal" vectors.
%
%   If REDUCE is true, duplicate normals will be combined.  No
%   floating-point tolerance is applied to do this: only identical
%   normals will be merged.
%
%   TO BE DONE:  The handling of zero-length edges and approximately equal
%   normals could be improved.

    numfaces = size(facevxs,1);
    numcorners = size(facevxs,2);
    cornervxs = reshape( vxs((facevxs+1)',:), numcorners, numfaces, 3 );
    vxnorm = cross( (cornervxs - circshift( cornervxs, 1, 1 )), (circshift( cornervxs, -1, 1 ) - cornervxs), 3 );
    perpvecnorms = sqrt( sum( vxnorm.^2, 3 ) );
    vxnorm = vxnorm ./ repmat( perpvecnorms, 1, 1, 3 );
    vxnorm(isnan(vxnorm)) = 0;
    vxnorm = reshape( vxnorm, [], 3 );
    
    % For CAD-type models, many components of these vectors will be 0 or
    % +/-1.  Rounding errors may disturb this.  Force all such components
    % to be exactly 0 or +/-1.
    TOLERANCE = 1e-9;
    vxnorm( abs(vxnorm) < TOLERANCE ) = 0;
    vxnorm( vxnorm-1 > -TOLERANCE ) = 1;
    vxnorm( vxnorm+1 < TOLERANCE ) = -1;
    has1 = any(abs(vxnorm)==1,2);
    vxnorm(abs(vxnorm(has1,:)) ~= 1) = 0;
    
    facevxnorm = reshape( 0:(numfaces*numcorners-1), numcorners, numfaces )';
    if reduce
        [vxnorm,~,ic] = unique( vxnorm, 'rows', 'stable' );
        facevxnorm = ic(facevxnorm+1)-1;
    end
end
