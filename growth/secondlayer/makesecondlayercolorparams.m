function cp = makesecondlayercolorparams( colors, colorvariation )
%cp = makesecondlayercolorparams( colors, colorvariation )
%   Given an N*3 array of RGB colours and an amount of colour variation
%   expressed in HSV space, calculate an N*6 array, each row of which
%   contains two HSV colours, being the original colours converted to HSV,
%   plus and minus the variation.

    h = rgb2hsv( colors );
    r = colorvariation; % rand(1,3)*colorvariation/2;
    cp = zeros( size(h,1), 6 );
    for i=1:size(h,1)
        cp(i,:) = [ h(i,:)-r, h(i,:)+r ];
    end
    % Saturation and value must be trimmed to the range 0...1.
    cp(:,[2 3 5 6]) = trimnumber( 0, cp(:,[2 3 5 6]), 1 );
    
    % The "low" hues are forced to the range 0..1, and the "high" hues to
    % the range of the "low" hues to 1 more than that.
    cp(:,4) = min( cp(:,4), cp(:,1)+1 );
    x = floor(cp(:,1));
    cp(:,1) = cp(:,1)-x;
    cp(:,4) = cp(:,4)-x;
end
