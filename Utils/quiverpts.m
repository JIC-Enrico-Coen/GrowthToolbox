function quiverpts( ax, x, v, varargin )
    if size(x,2)==2
        quiver( ax, x(:,1), x(:,2), v(:,1), v(:,2), varargin{:} );
    else
        quiver3( ax, x(:,1), x(:,2), x(:,3), v(:,1), v(:,2), v(:,3), varargin{:} );
    end
end
