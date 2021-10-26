function drawtetramesh( ax, vxs, tetras, varargin )
%drawtetramesh( ax, vxs, tetras, varargin )
%   Draw a tetrahedral mesh, given as an N*3 set of vertex positions and an
%   M*4 array of quadruples on vertex indexes.

    cla(ax);
    hold on;
    plotpts( vxs, 'ob', 'Parent', ax );
    
    edges = tetras( :, [1 2 1 3 1 4 2 3 2 4 3 4] );
    edges = unique( sort( reshape( edges', 2, [] )', 2 ), 'rows' );
    plotlines( edges, vxs, 'LineStyle','-', 'Color', 'r', 'Parent', ax );
    
    tetravxs = reshape( vxs(tetras',:), 4, [], 3 );
    centroids = sum( tetravxs, 1 )/4;
    plotpts(squeeze(centroids),'ok');
    multicentroids = repmat( centroids, 4, 1, 1 );
    tetravecs = tetravxs - multicentroids;
    shrunktetravxs = multicentroids + 0.5*tetravecs;
    for i=1:size(tetras,1)
        tvxs = squeeze( shrunktetravxs(:,i,:) );
        patch( 'Faces', [1 2 3;1 2 4;1 3 4;2 3 4], 'Vertices', tvxs, 'FaceAlpha', 0.5, 'FaceColor', rand(1,3) );
        pause
    end
    
    hold off;
end
