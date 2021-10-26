function bbox = unionBbox( bbox1, bbox2 )
    if isempty(bbox1)
        bbox = bbox2;
    elseif isempty(bbox2)
        bbox = bbox1;
    else
        bbox = [ min( bbox1([1 3 5]), bbox2([1 3 5]) ); ...
                 max( bbox1([2 4 6]), bbox2([2 4 6]) ) ];
        bbox = reshape( bbox, size(bbox2) );
    end
end
 