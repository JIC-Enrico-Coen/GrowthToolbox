function [bbox,bboxsize] = mesh_bbox( m )
    mn = min( m.prismnodes, [], 1 );
    mx = max( m.prismnodes, [], 1 );
    bbox = [ mn; mx ];
    if nargout > 1
        bboxsize = bbox(2,:) - bbox(1,:);
    end
end
