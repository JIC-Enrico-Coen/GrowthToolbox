function h = quivervec( p, v, varargin )
    h = quiver3( p(:,1), p(:,2), p(:,3), v(:,1), v(:,2), v(:,3), ...
        varargin{:} );
end
