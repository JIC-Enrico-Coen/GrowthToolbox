function p = flipCuboidIndexes( axis, divs )
%p = flipCuboidIndexes( axis, divs )
%
%   The standard numbering for the vertexes of a cuboid with the given
%   number of divisions each way is the one that lists them first in
%   increasing order of x, then increasing order of y, then increasing
%   order of z.
%
%   This procedure returns the indexing resulting from reflecting the
%   cuboid in the specified axis (given as a number 1=x, 2=y, 3=z).  More
%   than one axis can be given and all transformations will be applied.
%   They commute, so the order does not matter.
%
%   This works for any number of dimensions.  Axis indexes out of range are
%   ignored.
%
%   Examples:
%
%   An empty axis list returns 1:prod(divs).
%
%   If axis lists every dimension once, the result is prod(divs):-1:1.
%
%   flipCuboidIndexes( 1, [2 3] ) = [ 2 1 4 3 6 5 ];
%   flipCuboidIndexes( 2, [2 3] ) = [ 5 6 3 4 1 2 ];

    p = 1:prod(divs);
    numdims = length(divs);
    for i=1:length(axis)
        a = axis(i);
        if (a >= 1) && (a <= numdims)
            p = reshape( p, [ prod(divs(1:(a-1))), divs(a), prod(divs((a+1):end)) ] );
            p = p(:,end:-1:1,:);
            p = reshape(p,1,[]);
        end
    end
    return;
    
    switch axis
        case { 1, 'x' }
            p = [ 2 1 4 3 6 5 8 7 ];
        case { 2, 'y' }
            p = [ 3 1 4 2 7 5 8 6 ];
        case { 3, 'z' }
            p = [ 5 1 6 2 7 3 8 4 ];
        otherwise
            p = [ 1 2 3 4 5 6 7 8 ];
    end
end