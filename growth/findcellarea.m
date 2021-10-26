function a = findcellarea( m, ci )
    a = trianglearea( m.nodes( m.tricellvxs( ci, : ), : ) );
end
