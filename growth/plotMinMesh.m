function plotMinMesh( m )
%plotMinMesh( m )
%   Minimal plotting routine that assumes only the node and tricellvxs
%   fields.
% NEVER USED.  Needs updated to draw lines more efficiently.

    tnodes = reshape( m.nodes( m.tricellvxs', : ), 3, [], 3 );
    tnodes(4,:,:) = tnodes(1,:,:);
    cla;
    line( tnodes(:,:,1), ...
          tnodes(:,:,2), ...
          tnodes(:,:,3), ...
          'LineWidth', 2 );
          % 'LineSmoothing', 'on' );  % LineSmoothing is deprecated.
    axis equal;
end
