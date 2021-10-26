function [r,semiaxes,centre] = randInEllipse( n, a, b )
%r = randInEllipse( n )
%	Uniform distribution on the unit circle.
%
%r = randInEllipse( n, bbox )
%	Uniform distribution on an axis-aligned ellipse with specified bounding
%	box.
%
%r = randInEllipse( n, a, b )
%	Uniform distribution on an ellipse of specified semi-axes A and B,
%	centred on the origin.
%
%   The result is an N*2 array.

    switch nargin
        case 1
            bbox = [-1 1 -1 1];
        case 3
            bbox = [-a a -b b];
        otherwise
            bbox = a;
    end
    
    semiaxes = (bbox([2 4]) - bbox([1 3]))/2;
    centre = (bbox([2 4]) + bbox([1 3]))/2;

    angle = 2.0 * pi * rand(n,1);
    radius = sqrt ( rand(n,1) );

    r = (semiaxes .* radius) .* [ cos(angle), sin(angle) ] + centre;
end
