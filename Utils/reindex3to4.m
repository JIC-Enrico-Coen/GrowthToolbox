function [ri,gi] = reindex3to4( v3, v4 )
%ri = reindex3to4( v3, v4 )
% v3 is N*K1, v4 is N*K2, where K2 >= K1.  Every row of both v3 and v4
% contains no repeated values.  Each row of v3 is a subset of the
% corresponding row of v4.  The result is an array, the same size as v3,
% that says which column of v4 each member of v3 is equal to.

    % Make all elements of v3 unique, and all elements of v4.
    step = max( max(v3(:)), max(v4(:)) );
    increment = (0:step:(step*(size(v3,1)-1)))';
    v3x = v3 + repmat( increment, 1, size(v3,2) );
    v4x = v4 + repmat( increment, 1, size(v4,2) );

    [sect,ia,gi] = intersect( v3x(:), v4x(:), 'stable' );
    % sect is identical to v3(:).
    % ia will be (1:numel(v3))'.
    % Only gi is needed.
    [x,y] = ind2sub( size(v4), gi );
    % reshape(x,size(v3)) will be identical to
    % repmat( (1:size(v3,1))', 1, size(v3,2) )
    ri = reshape( y, size(v3) );
end
