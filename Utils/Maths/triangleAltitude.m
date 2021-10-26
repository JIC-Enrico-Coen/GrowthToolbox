function vxD = triangleAltitude( vxA, vxB, vxC )
%vxD = triangleAltitude( vxA, vxB, vxC )
%	D is the foot of the altitude from A to the line BC.
%   vxA, vxB, and vxC are expected to be row vectors.  Any of them may be
%   matrices of more than one row vectors; if more than one is, they must
%   contain the same number of rows, and if any is a single vector it will
%   be replicated the required number of times.

    if size(vxB,1) ~= size(vxC,1)
        if size(vxB,1) == 1
            vxB = repmat( vxB, size(vxC,1), 1 );
        else
            vxC = repmat( vxC, size(vxB,1), 1 );
        end
    end
    BC = vxC-vxB;
    if size(vxA,1) ~= size(vxC,1)
        if size(vxA,1) == 1
            vxA = repmat( vxA, size(vxC,1), 1 );
        else
            vxC = repmat( vxC, size(vxA,1), 1 );
            vxB = repmat( vxB, size(vxA,1), 1 );
            BC = repmat( BC, size(vxA,1), 1 );
        end
    end
    AdotCB = dot(vxA,BC, 2);
    BdotCB = dot(vxB,BC, 2);
    CdotCB = dot(vxC,BC, 2);
    p = bc2( AdotCB, BdotCB, CdotCB );
    vxD = repmat(1-p,1,3).*vxB + repmat(p,1,3).*vxC;
end

function p = bc2( a, b, c )
% P is the number having the property that a = (1-p)b + pc.  It will be Inf
% if c==b.  a, b, and c can be matrices of any size if they are all the
% same shape.
    p = (a-b)./(c-b);
end
