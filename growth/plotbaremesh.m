function plotbaremesh( m, ax )
%plotbaremesh( m, ax )
%   Plot a mesh which only contains m.nodes and m.tricellvxs.
%   AX defaults to gca().

    if nargin < 2
        ax = gca();
    end
    x = reshape( m.nodes( m.tricellvxs', 1 ), 3, [] );
    y = reshape( m.nodes( m.tricellvxs', 2 ), 3, [] );
    z = reshape( m.nodes( m.tricellvxs', 3 ), 3, [] );
    fill3( x, y, z, 'w', 'Parent', ax );
end
