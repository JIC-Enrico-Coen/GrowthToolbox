function plotMinMeshClip( m, n, a )
%plotMinMeshClip( m, n, a )
%   Minimal plotting routine plus clipping plane.  N is a column vector and A
%   is a real number.
% NEVER USED.  Needs updating to plot lines more efficiently.

    if nargin < 3
        a = 0;
    end
    if nargin < 2
        n = [ 1; 0; 0 ];
    end

    side = planeSide( n, a, m.nodes );
    plottableCells = all( side( m.tricellvxs' ) );
    tnodes = reshape( m.nodes( m.tricellvxs(plottableCells,:)', : ), 3, [], 3 );
    tnodes(4,:,:) = tnodes(1,:,:);
    cla;
    line( tnodes(:,:,1), ...
          tnodes(:,:,2), ...
          tnodes(:,:,3), ...
          'LineWidth', 2 );
          % 'LineSmoothing', 'on' );  % LineSmoothing is deprecated.
    axis equal;
end
