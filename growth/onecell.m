function mesh = onecell( x, y )
%mesh = onecell( x, y )
%   Make a mesh consisting of a single triangle with vertexes at
%   [0,0,0], [x,0,0], and [0,y,0].

    if nargin < 1, x = 1; end
    if nargin < 2, y = 1; end

    numnodes = 3;
    numedges = 3;
    numcells = 1;

  % mesh = setemptymesh( numnodes, numedges, numcells );
    mesh.globalProps.trinodesvalid = true;
    mesh.globalProps.prismnodesvalid = false;
    
%     mesh.nodes = [ ...
%         [ -x/2, -y/3, 0 ]; ...
%         [ x/2, -y/3, 0 ]; ...
%         [ 0, y*2/3, 0 ] ...
%     ];
    mesh.nodes = [ ...
        0 0 0; ...
        x 0 0; ...
        0 y 0 ...
    ];
    mesh.tricellvxs = int32( [ 1, 2, 3 ] );
end
