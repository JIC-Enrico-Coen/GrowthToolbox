function pts = circlepoints( radius, centre, numpts, angleOffset, v1, v2 )
    if nargin < 4
        angleOffset = 0;
    end
    if nargin < 5
        v1 = zeros(1,length(centre));
        v1(1) = 1;
    end
    if nargin < 6
        v2 = zeros(1,length(centre));
        v2(2) = 1;
    end
    numpts = double(numpts);

    angles = (((0:(numpts-1)) + angleOffset)*(pi*2/numpts))';
    pts = (cos(angles)*v1 + sin(angles)*v2)*radius;
    
    for i=1:numpts
        pts(i,:) = pts(i,:) + centre;
    end
end
