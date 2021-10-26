function [pts,scaling,oldcentre,newcentre] = fitToBbox( pts, bbox, isotropic )
    if isempty(pts)
        scaling = [1 1 1];
        oldcentre = [0 0 0];
        newcentre = oldcentre;
        return;
    end
    if nargin < 3
        isotropic = true;
    end
    ptsmin = min(pts,[],1);
    ptsmax = max(pts,[],1);
    oldcentre = (ptsmax + ptsmin)/2;
    if isempty(bbox)
        scaling = [1 1 1];
        newcentre = oldcentre;
        return;
    end
    ptssize = ptsmax - ptsmin;
    newcentre = (bbox([1 3 5]) + bbox([2 4 6]))/2;
    bboxsize = bbox([2 4 6]) - bbox([1 3 5]);
    scaling = bboxsize./ptssize;
    scaling(isinf(scaling)) = NaN;
    if all(isnan(scaling))
        scaling = [1 1 1];
        return;
    end
    if isotropic
        scaling = repmat( min(scaling), 1, length(scaling) );
    else
        scaling(isnan(scaling)) = 1;
    end
    for i=1:size(pts,2)
        pts(:,i) = (pts(:,i) - oldcentre(i))*scaling(i) + newcentre(i);
    end
end

