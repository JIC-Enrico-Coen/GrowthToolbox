function percell = perVertexToPerCell( m, perFEvertex )
%percell = perVertexToPerCell( m, pervertex )
%   Convert a per-FE-vertex quantity to a per-cell quantity.
%
%   DEPRECATED: Use the renamed version perFEVertexToPerCell().

    percell = perFEVertexToPerCell( m, perFEvertex );
end
