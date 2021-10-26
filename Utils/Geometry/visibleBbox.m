function bbox = visibleBbox( ax )
    c = get( ax, 'Children' );
    bbox = [];
    for i=1:length(c)
        switch lower( get(c(i),'Type') )
            case 'line'
                xyz = [ get(c(i),'XData'); get(c(i),'YData'); get(c(i),'ZData') ];
                bbox1 = [min(xyz,[],2), max(xyz,[],2)]';
            case 'patch'
                xyz = get(c(i),'Vertices');
                bbox1 = [min(xyz,[],1); max(xyz,[],1)];
            otherwise
                continue;
        end
        if i==1
            bbox = bbox1;
        else
            bbox = unionBbox( bbox, bbox1 );
        end
    end
end

            