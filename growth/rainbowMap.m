function [c,range] = rainbowMap( range, midwhite, nsteps )
%[c,range] = rainbowMap( range, midwhite )
%   Create a rainbow map and an updated range.
%   The given range is two or three elements.
%   midwhite is boolean.
%
%   When midwhite is false, the scale goes from blue to red and covers the
%   given range.  range(3), if present, is ignored.
%
%   When midwhite is true, the scale goes from violet to white to blue to
%   red.  range(3) defaults to zero.  range([1 2]) is extended to include
%   range(3).  Then a notional range is construted.

    if nargin < 2
        midwhite = true;
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
%     midwhite = midwhite || (length(range) > 2);
    if length(range) > 2
        zrange = range;
    elseif midwhite
        zrange = [ range min( max( 0, range(1) ), range(2) ) ];
    else
        zrange = [ range min(range) ];
    end
    if (nargin < 3) || isempty(nsteps)
        nsteps = 50;
    end
    
    
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
