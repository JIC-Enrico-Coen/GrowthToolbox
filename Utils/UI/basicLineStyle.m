function [lw,ls,vw,vs] = basicLineStyle( linewidth, pointsize )
%[lw,ls,vw,vs] = basicLineStyle( linewidth, pointsize )
%   Because Mathworks don't think zero is a number.
%   pointsize is optional. If absent, vw and vs are not returned.

    if linewidth <= 0
        lw = 1;
        ls = 'none';
    else
        lw = linewidth;
        ls = '-';
    end
    
    if nargin >= 2
        if pointsize <= 0
            vw = 1;
            vs = 'none';
        else
            vw = pointsize;
            vs = '.';
        end
    end
end
