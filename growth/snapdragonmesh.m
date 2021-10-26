function m = snapdragonmesh( petals, radius, rings, height, nrows, nbase, thickness )
%m = snapdragonmesh( petals, radius, rings, height, nbase, nrows )
% Make a snapdragon flower.
%   The resulting mesh contains only the following components:
%   nodes, tricellvxs, prismnodes, globalProps.trinodesvalid,
%   globalProps.prismnodesvalid, and borders.{bottom,left,right}.

    loberadius = pi*radius/petals;
    m = lobesmesh( petals, loberadius, rings, height, nrows, nbase );
    dz = thickness*radius/2; % *5*radius/(2*pi)  % loberadius/(rings*3);
    m.prismnodes = ...
        reshape( ...
            [ [m.nodes(:,[1 2]), m.nodes(:,3)+dz]';
              [m.nodes(:,[1 2]), m.nodes(:,3)-dz]' ], ...
          3, [] )';
    m = wrapmesh( m, radius );
    m = stitchmesh( m, m.borders.right, m.borders.left );
    m.globalProps.trinodesvalid = true;
    m.globalProps.prismnodesvalid = true;
end
