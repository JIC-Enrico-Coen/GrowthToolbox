function plotbaremesh( m )
%plotbaremesh( m )
%   Plot a mesh which only contains m.nodes and m.tricellvxs.

    x = reshape( m.nodes( m.tricellvxs', 1 ), 3, [] );
    y = reshape( m.nodes( m.tricellvxs', 2 ), 3, [] );
    z = reshape( m.nodes( m.tricellvxs', 3 ), 3, [] );
    fill3( x, y, z, 'b' );
end
