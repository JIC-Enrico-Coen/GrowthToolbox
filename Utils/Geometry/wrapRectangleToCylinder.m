function cylpts = wrapRectangleToCylinder( rectpts, rectbbox, cylbbox, radius )
%pts = wrapRectangleToCylinder( pts, rectbbox, cylbbox )
%   Define a transformation from the bounding box of the rectangle to the
%   bounding box on the cylinder of given radius, and use it to transform
%   the points.
%
%   rectbbox has the form [xlo xhi ylo yhi].
%   cylbbox has the form [thetalo thetahi zlo zhi].
%   The x coordinate of the rectangle is mapped to the theta of the
%   cylinder, and the y of the rectangle to the z of the cylinder.

    xrange = rectbbox(2)-rectbbox(1);
    thetarange = cylbbox(2)-cylbbox(1);
    ptheta = cylbbox(1) + (thetarange/xrange)*(rectpts(:,1) - rectbbox(1));
    c = radius*cos(ptheta);
    s = radius*sin(ptheta);
    yrange = rectbbox(4)-rectbbox(3);
    zrange = cylbbox(4)-cylbbox(3);
    x = rectpts(:,1).*c + rectpts(:,2).*s;
    y = -rectpts(:,1).*s + rectpts(:,2).*c;
    z = cylbbox(3) + (zrange/yrange)*(rectpts(:,2) - rectbbox(3));
    cylpts = [ c, s, z ];
end
