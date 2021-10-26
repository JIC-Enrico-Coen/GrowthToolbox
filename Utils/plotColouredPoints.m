function h = plotColouredPoints( ax, pts, v, cmap, crange, marksize )
    if (nargin < 5) || isempty(crange)
        crange = [ min(v), max(v) ];
    end
    if (nargin < 6) || isempty(marksize)
        marksize = 10;
    end
    [~,cwhole] = interpolateArray( v, cmap, crange, true );
    h = -ones(size(cmap,1),1);
    for ci=1:size(cmap,1)
        vi = cwhole==ci;
        p = pts(vi,:);
        if ~isempty(p)
            h(ci) = line(p(:,1),p(:,2),p(:,3), ...
                'Parent', ax, ...
                'Marker','o', ...
                'LineStyle', 'none', ...
                'MarkerSize', marksize, ...
                'MarkerFaceColor',cmap(ci,:), ...
                'MarkerEdgeColor',cmap(ci,:) );
        end
    end
    h = h(h~=-1);
end
