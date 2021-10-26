function d = colorDistance( h1, h2, colorspace )
%d = colorDistance( rgb1, rgb2 )
%   A very crude estimate of psychological color distance.

    if nargin < 3
        colorspace = 'rgb';
    end
    if strcmp(colorspace,'rgb')
        h1 = rgb2hsv(h1);
        h2 = rgb2hsv(h2);
    end
    hueweight = 6;
    satweight = 1;
    valweight = 1;
    huediff = h1(:,1)-h2(:,1);
    hueaverage = (h1(:,1)+h2(:,1))/2;
    a = 0.2;
    b = 4*(1-a);
    huediffweights = a + b*(hueaverage-0.5).^2;
    huediff = min( abs(huediff), 1-abs(huediff) ) ...
              .* (h1(:,2)+h2(:,2)) .* (h1(:,3)+h2(:,3)) * hueweight/4;
    satdiff = (h1(:,2)-h2(:,2)).^2 * satweight;
    valdiff = (h1(:,3)-h2(:,3)) * valweight;
    d = sqrt( huediff.*huediff + satdiff.*satdiff + valdiff.*valdiff ) ...
        .* huediffweights .* (h1(:,2)+h2(:,2));
    return;

    weights = [1, 0.5, 0.5];
    weights = weights/norm(weights);
    r = (rgb1(:,1)-rgb2(:,1))*weights(1);
    g = (rgb1(:,2)-rgb2(:,2))*weights(2);
    b = (rgb1(:,3)-rgb2(:,3))*weights(3);
    d = sqrt( r.*r + b.*b + g.*g );
end
