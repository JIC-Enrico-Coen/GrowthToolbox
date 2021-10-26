function sense = vxpairsense( vxpair, vxtri )
%sense = vxpairsense( vxpair, vxtri )
%   vxpair is an N*2 array. Each row is a pair of distinct values.
%   vxtri is an N*3 array. Each row consists of three distinct values.
%
%   For each row, we determine whether vxpair(i,2) immediately follows
%   vxpair(i,1) in vxtri(:,1), considered cyclically. sense is true where
%   this is so, false otherwise.

    status = sum( ((repmat( vxpair(:,1), 1, 3 )==vxtri) - (repmat( vxpair(:,2), 1, 3 )==vxtri)) * [1;2;4], 2 ) + 4;
    % status has six possible values, according to where the two values
    % occur in the triple:
    % v1 v2 x: 3
    % v2 v1 x: 5
    % v2 x v1: 7
    % v1 x v2: 1
    % x v1 v2: 2
    % x v2 v1: 6
    % Values 2, 3, and 7 are positive sense.
    sense = (status==2) | (status==3) | (status==7);
end
