function outside = bbfar( pts, p, d )
% Test whether p lies outside the bounding box of the set of points pts by
% a distance of at least d.

    outside = false;
    
    if isinf(d)
        return;
    end
    
    for i=1:size(p,2)
        d1 = pts(:,i)-p(i);
        if all(d1 <= -d) || all(d1 >= d)
            outside = true;
            return;
        end
    end
end
