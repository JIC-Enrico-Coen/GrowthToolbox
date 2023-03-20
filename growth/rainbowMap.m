function [c,range] = rainbowMap( range, midwhite, nsteps )
%[c,range] = rainbowMap( range, midwhite )
%   Create a rainbow map covering the given range of values, with the given
%   number of steps.
%
%   range(1) and range(2) are the lower and upper bounds of the values to
%   be mapped to colors.
%
%   If midwhite is false, the colour scale goes from blue at range(1) to
%   dark red at range (2), traversing the spectrum through green, yellow,
%   orange, and bright red.
%
%   If midwhite is true, the scale goes from violet at range(1), to white
%   at 0, then through the color scale as before from blue to dark red at
%   range(2). The colour mapping is performed so that the values mapped to
%   the extremes of violet and dark red are equal and opposite. Only the
%   part spanning the interval from range(1) to range(2) is returned. If
%   the range given does not include zero, it will be expanded so that it
%   does. This expanded range is returned as the second result.
%
%   The color map c is returned as an (nsteps+1)*3 array, i.e. nsteps is
%   the number of intervals, 1 less than the number of colours.
%
%   The range output is the same as the range input, except when midwhite
%   is true and the given range does not include zero. It will be extended
%   to do so.


%   Although the code below envisages the possibility that range has 3
%   elements, the third value should not be used. It will be replaced by
%   zero anyway. It represents the value to be mapped to white, but in fact
%   the value mapped to white (when midwhite is true) is always zero. This
%   is an error that is not worth fixing.

    if nargin < 2
        midwhite = true;
    end
    if (nargin < 3) || isempty(nsteps)
        nsteps = 50;
    end
    
    if midwhite
        range = extendToZero( range );
    end
    if range(1)==range(2)
        c = [1 1 1;1 1 1];
        return;
    end
    if ~midwhite
        range(3) = range(1);
    end
    if length(range) > 2
        zrange = range;
    elseif midwhite
        zrange = [ range min( max( 0, range(1) ), range(2) ) ];
    else
        zrange = [ range min(range) ];
    end
    
    % The values mapped to the colors in poscolors are equally spaced.
    % Other values will be mapped by linear interpolation in RGB
    % coordinates. Values outside the range will be mapped to the
    % corresponding extreme of the range. Similarly for negcolors.
    % The choice of these lists of colors was made by personal taste of
    % the author.
    
    poscolors = [ 0 0 1       % blue
                  0 0.7 1     % bluish cyan
                  0 1 1       % cyan
                  0 1 0.7     % greenish cyan
                  0 1 0       % green
                  0.75 1 0    % chartreuse
                  1 1 0       % yellow
                  1 0.875 0   % yellow-orange
                  1 0.5 0     % orange
                  1 0 0       % red
                  2/3 0 0 ];  % darker red
    if midwhite
        poscolors = [ 1 1 1; poscolors ];
        negcolors = [ 1 1 1         % white
                      0.9 0 1       % purple
                      0.45 0 0.5 ]; % dark purple
        c = posnegMap( zrange, negcolors, poscolors, nsteps );
    else
        c = makeCmap( poscolors, nsteps );
    end
end
