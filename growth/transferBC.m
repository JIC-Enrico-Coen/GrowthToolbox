function bc2 = transferBC( m, ci1, bc, ci2 )
%[cj,bcj] = transferEdgeBC( m, ci, bc )
%   Given barycentric coordinates bc of a point on the boundary of a
%   triangle ci1 of m, find the barycentric coordinates of the same point
%   relative to the triangle ci2. The point is assumed to be common to
%   both, either by a shared edge or a shared vertex. If it is not, bc2
%   is returned as empty.

    bc1i = find( bc >= 1, 1 );
    if isempty(bc1i)
        % The point is in the interior of an edge. This must also be an
        % edge of ci2.
        bc1i = find( bc <= 0, 1 );
        if isempty(bc1i)
            bc2 = [];
        else
            e1 = m.celledges(ci1,bc1i);
            es2 = m.celledges(ci2,:);
            bc2i = find( es2==e1, 1 );
            if isempty(bc2i)
                bc2 = [];
            else
                [bc1j, bc1k] = othersOf3( bc1i );
                [bc2j, bc2k] = othersOf3( bc2i );
                bc2( [bc2i, bc2j, bc2k] ) = bc( [bc1i, bc1k, bc1j] );
            end
        end
    else
        % The point is a vertex of ci1. It must also be a vertex of ci2.
        vx1 = m.tricellvxs(ci1,bc1i);
        cvxs2 = m.tricellvxs(ci2,:);
        bc2i = find( cvxs2==vx1, 1 );
        if isempty(bc2i)
            bc2 = [];
        else
            bc2 = [0 0 0];
            bc2(bc2i) = 1;
        end
    end
end