function [r,semiaxes,centre] = randInSemiEllipse( n, bbox, ax )
%r = randInEllipse( n, bbox, ax )
%	Uniform distribution on an axis-aligned semi-ellipse with specified bounding
%	box. AX specifies which half of the ellipse is present, and is one of
%	'+X', '-X', '+Y', or '-Y'.

    switch ax
        case '+X'
            fullbbox = [ 2*bbox(1)-bbox(2), bbox([2 3 4]) ];
        case '-X'
            fullbbox = [ bbox(1), 2*bbox(2)-bbox(1), bbox([3 4]) ];
        case '+Y'
            fullbbox = [ bbox([1 2]), 2*bbox(3)-bbox(4), bbox(4) ];
        case '-Y'
            fullbbox = [ bbox([1 2 3]), 2*bbox(4)-bbox(3) ];
        otherwise
            return;
    end
            
    semiaxes = (fullbbox([2 4]) - fullbbox([1 3]))/2;
    centre = (fullbbox([2 4]) + fullbbox([1 3]))/2;
    
    r = randInEllipse( n, semiaxes(1), semiaxes(2) );
    switch ax
        case '+X'
            r(:,1) = abs( r(:,1) );
        case '-X'
            r(:,1) = -abs( r(:,1) );
        case '+Y'
            r(:,2) = abs( r(:,2) );
        case '-Y'
            r(:,2) = -abs( r(:,2) );
    end
    r = r + centre;
end
