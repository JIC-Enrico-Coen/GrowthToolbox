function rgbcontrast = contrastenColor( rgb, todark, tolight )
%rgbcontrast = contrastenColor( rgb, todark, tolight )
%   Increase the contrast of a color. RGB is an N*3 array of colors, whose
%   values are in the range 0..1. TODARK specifies how much to scale each
%   color towards black, and TOLIGHT how much towards light. If only one of
%   these is given, its value is used for both.
%
%   If RGB is an N*3 array of colors, then the colors are scaled
%   independently. TODARK and TOLIGHT can be single values or a value per
%   color.
%
%   A zero value of TODARK or TOLIGHT means no effect. 1 means maximum
%   effect.

    if nargin < 3
        tolight = todark;
    end
    todark = todark(:);
    tolight = tolight(:);
    
    cellrgb = iscell(rgb);
    if cellrgb
        cellrgbsize = size( rgb );
        rgb = cell2mat( rgb(:) );
    end
    
    minrgb = min( rgb, [], 2 );
    maxrgb = max( rgb, [], 2 );
    newminrgb = minrgb .* (1 - todark);
    newmaxrgb = 1 - (1 - maxrgb) .* (1 - tolight);
    scaling = (newmaxrgb - newminrgb)./(maxrgb - minrgb);
    dontscale = minrgb==maxrgb;
    
    rgbcontrast = (rgb - minrgb) .* scaling + newminrgb;
    rgbcontrast(dontscale,:) = rgb(dontscale,:);
    if cellrgb
        rgbcontrast = reshape( num2cell( rgbcontrast, 2 ), cellrgbsize );
    end
end
