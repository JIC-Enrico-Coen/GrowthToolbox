function [c,cwhole,cfrac] = interpolateArray( v, cmap, crange, discrete )
%c = interpolateArray( v, cmap, crange )
%   C is the color produced by mapping V into the color map CMAP.  Values
%   of V outside the range are replace by the endpoints of the range.
%   CWHOLE is the index of the row of CMAP that is the lower end of the
%   interval into which the value falls, and CFRAC is the fraction of the
%   way to the next colour.
%   If DISCRETE is true (the default is false) then the value will be
%   rounded to the nearest point on the scale.  In this case CFRAC will
%   consist of zeroes.
%   V can be a column vector of length N and C will be an N*3 matrix.

    if nargin < 4
        discrete = false;
    end
    if nargin < 3
        crange = [0 1];
    end
    ncolors = size(cmap,1);
    if (ncolors==1) || (crange(2) <= crange(1))
        cwhole = ones(length(v),1);
        c = cwhole*cmap(1,:);
        if nargout >= 3
            cfrac = zeros(length(v),1);
        end
        return;
    end
    scale = (ncolors-1)/(crange(2)-crange(1));
    cv = 1 + (v(:) - crange(1))*scale;
    cv(cv<1) = 1;
    cv(cv>ncolors) = ncolors;
    if discrete
        cwhole = round(cv);
        c = cmap(cwhole,:);
        if nargout >= 3
            cfrac = zeros(length(v),1);
        end
    else
        cvfrac = mod(cv,1);
        cvwhole = int32(cv - cvfrac);
        dcolors = size(cmap,2);
        csteps = [cmap(2:end,:)-cmap(1:(end-1),:); zeros(1,dcolors)];
        c = cmap(cvwhole,:) + csteps(cvwhole,:).*repmat( cvfrac, 1, dcolors );
    end
end
