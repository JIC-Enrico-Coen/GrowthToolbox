function [d,pp] = pointTriangleDistance( vxs, p )
%d = pointTriangleDistance( vxs, p )
%   Find the distance from a point to a triangle.

    [pp,bc] = projectPointToPlane( vxs, p );
    
    if bc(1) < 0
        % - ? ?
        if bc(2) < 0
            % - - +
            fprintf( 1, 'Closest to vertex 3.\n' );
            pp = vxs(3,:);
            d = norm(p-pp);
        elseif bc(3) < 0
            % - + -
            fprintf( 1, 'Closest to vertex 2.\n' );
            pp = vxs(2,:);
            d = norm(p-pp);
        else
            % - + +
            fprintf( 1, 'Closest to side 23.\n' );
            [d,pp] = pointLineDistance( vxs([2 3],:), p );
        end
    elseif bc(2) < 0
        % + - ?
        if bc(3) < 0
            % + - -
            fprintf( 1, 'Closest to vertex 1.\n' );
            pp = vxs(3,:);
            d = norm(p-pp);
        else
            % + - +
            fprintf( 1, 'Closest to side 31.\n' );
            [d,pp] = pointLineDistance( vxs([3 1],:), p );
        end
    elseif bc(3) < 0
        % + + -
        fprintf( 1, 'Closest to side 12.\n' );
        [d,pp] = pointLineDistance( vxs([1 2],:), p );
    else
        % + + +
        fprintf( 1, 'Closest to face 123.\n' );
        d = norm(p-pp);
    end
end
