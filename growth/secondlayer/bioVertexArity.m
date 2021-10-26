function arity = bioVertexArity( secondlayer )
    vxs = secondlayer.edges(:,[1 2]);
    vxs = sort(vxs(:));
    ends = [ find( vxs( 1:(end-1) ) ~= vxs( 2:end ) ); length(vxs) ];
    starts = [ 1; 1+ends(1:(end-1)) ];
    arity = ends-starts+1;
end
