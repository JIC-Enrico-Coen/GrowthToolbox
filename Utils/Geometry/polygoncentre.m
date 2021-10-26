function centre = polygoncentre( vxs )
%centre = polygoncentre( vxs )
%   Find the centroid of a polygon.

    numvxs = size( vxs, 1 );
    if size(vxs,2)==2
        vxs = [ vxs zeros( numvxs, 1 ) ];
    end
    vxav = sum( vxs, 1 )/numvxs;
    xx = [2:numvxs 1];
    offsets = vxs - repmat( vxav, numvxs, 1 );
    areas = sqrt( sum( cross( offsets, offsets(xx,:), 2 ).^2, 2 ) )/2;
    relcentres = (offsets + offsets(xx,:)) * (1/3);
    centre = vxav + (areas' * relcentres)/sum(areas);
end
