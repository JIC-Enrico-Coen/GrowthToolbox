function bcj = transferVertexBC( m, ci, bc, newci )
%bcj = transferVertexBC( m, ci, bc, newci )
%   Given barycentric coordinates bc of a vertex of a cell ci of
%   m, find the barycentric coordinates of the same point relative to
%   another element newci that also has that vertex.

    cei = find(bc>=1,1);
    vi = m.tricellvxs(ci,cei);
    cej = find( m.tricellvxs(newci,:)==vi, 1 );
    bcj = [0 0 0];
    bcj(cej) = 1;
end