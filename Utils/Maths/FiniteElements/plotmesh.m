function h = plotmesh( ax, vxcoords, cellvxs, edges )
    if nargin==3
        edges = cellvxs;
        cellvxs = vxcoords;
        vxcoords = ax;
        ax = gca;
    end
    if isempty(edges)
        nv = size(cellvxs,2);
        edges = [ (1:nv)' [2:nv 1]' ];
    end
    if ~isempty( edges )
        alledges = cellvxs(:,edges(:)')';
        oldhold = get( ax, 'NextPlot' );
        hold(ax,'on');
        if size(vxcoords,2)==2
            h = line( reshape(vxcoords(alledges,1),2,[]), ...
                      reshape(vxcoords(alledges,2),2,[]), ...
                      'Color', 'b', 'Tag', 'meshgrid' );
            plot( vxcoords(:,1), vxcoords(:,2), '.b', 'MarkerSize', 20 );
        else
            h = line( reshape(vxcoords(alledges,1),2,[]), ...
                      reshape(vxcoords(alledges,2),2,[]), ...
                      reshape(vxcoords(alledges,3),2,[]), ...
                      'Color', 'b', 'Tag', 'meshgrid' );
            plot3( vxcoords(:,1), vxcoords(:,2), vxcoords(:,3), '.b', 'MarkerSize', 20 );
        end
        set( ax, 'NextPlot', oldhold );
    end
end

