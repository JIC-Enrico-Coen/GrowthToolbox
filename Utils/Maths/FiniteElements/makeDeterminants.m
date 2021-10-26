function dets = makeDeterminants( vxs, detixs )
% vxs is an N*3 set of vectors.  detixs is a K*3 or K*2 array of indexes
% into the first dimension of vxs.
%
% If detixs is K*3, then the determinant is calculated of each of the
% triples of rows of VXS it specifies.
%
% If detixs is K*3, then for each of the pairs of rows of VXS it specifies,
% the norm of the cross product of those vectors is calculated.  This is
% equivalent to the determinant of those two vectors combined with their
% common unit normal.  Note that in this case the determinant is always
% non-negative.

    if size(vxs,2)==2
        vxs = [ vxs, zeros(size(vxs,1),1) ];
    end
    dets = zeros( size(detixs,1), 1 );
    if size(detixs,2)==3
        for i=1:size(detixs,1)
            dets(i) = det( vxs(detixs(i,:), : ) );
        end
    else
        for i=1:size(detixs,1)
            dets(i) = norm(cross( vxs(detixs(i,1), : ), vxs(detixs(i,2), : ) ) );
        end
    end
end
