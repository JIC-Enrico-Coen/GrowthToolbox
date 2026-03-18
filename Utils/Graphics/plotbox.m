function h = plotbox( ax, bbox, varargin )
%plotbox( ax, bbox, ... )
% Plot an axis-aligned box whose bounds are BBOX in the order
% [ XLO YLO ZLO; XHI YHI ZHI ]. The remaining arguments will be passed to a
% call of PATCH.
%
% The result is a handle to the patch object.

    vxs = bbox( [1 3 5;
                 2 3 5;
                 1 4 5;
                 2 4 5;
                 1 3 6;
                 2 3 6;
                 1 4 6;
                 2 4 6 ] );
    faces = [ 1 5 7 3;
              2 4 8 6;
              1 2 6 5;
              3 7 8 4;
              1 3 4 2;
              5 6 8 7 ];
    h = plotpolys( ax, vxs, faces, varargin{:} );
end
                 