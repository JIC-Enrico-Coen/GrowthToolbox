function plotcolouredlines( ax, vxs, ends, colors, varargin )
    if ~isempty(ends)
        x = reshape( vxs(ends',1), 2, [] );
        y = reshape( vxs(ends',2), 2, [] );
        if size(vxs,2)==2
            plotpts( ax, vxs, 'ok' );
            for i=1:size(x,2)
                plot( ax, x(:,i), y(:,i), 'Color', colors(i,:), varargin{:} );
            end
        else
            z = reshape( vxs(ends',3), 2, [] );
            for i=1:size(x,2)
                plot3( ax, x(:,i), y(:,i), z(:,i), 'Color', colors(i,:), varargin{:} );
            end
        end
    end
end
