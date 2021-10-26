function m = splitBadNodes( m, ang )
%m = splitBadNodes( m, ang )
%   Find nodes with incident angles of less than ang, and split as many as
%   possible.


    [n,c1,bc1,c2,bc2,e1,e2] = findNodesToSplit( m, ang )
    for i=1:length(n)
        if c1(i)
            m = splitnode( m, n(i), c1(i), bc1(i,:), c2(i), bc2(i,:), e1(i), e2(i) );
        else
            fprintf( 1, 'splitBadNodes: no data for node %d.\n', n(i) );
        end
    end
end
