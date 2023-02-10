function [cmap,range] = monoColormap( range, hues, split, steps )
%[cmap,range] = monoColormap( range, hues )
%   Create a monochromatic colour map.  RANGE is either two values (min and
%   max) or three (min, max, and mid).  If the mid value is not
%   specified, it defaults to zero.
%
%   hues specifies either 1, 2, or 3 colours.
%   If 1 colour, that is the colour used for the maximum value.  The
%   opposite colour is used for the minimum, and white for the middle
%   value.
%   If 2 colours, the first is for the minimum value and the second for the
%   maximum, with white for the middle value.
%   If 3 colours, these are for the min, mid, and max values.
%   HUES can consist of RGB values or be a string of one-character names of
%   colours.  These are characters in the set k, w, r, g, b, c, m, y, o, a.
%   The first eight of these are Matlab standard names,  'o' is orange and
%   'a' is gray.
%   HUES can also be a set of 1, 2, or 3 numbers in the range 0..1.  These
%   represent fully saturated, fully bright hues.  0 and 1 both represent
%   red.  Increasing numbers from zero go through orange, yellow, green,
%   blue, and violet, and back to red.
%
%   When split is false, the colour scale will go from the the mid
%   colour to the max colour.  The min colour is ignored.  The range of
%   values will be the supplied interval range([1 2]).  The mid value is
%   ignored.
%
%   When split is true, all three colours and all three elements of the
%   range may be used.  The interval range([1 2]) is expanded if necessary
%   to include the mid value.  That is the range that will be returned.
%   If the mid value equals the min value, a colour map from the mid to the
%   mx colour is returned.  If mid==max, a colour map from the min to the
%   mid colour is returned.  If min < mid < max, a notional value range is
%   constructed by expanding the interval range([1 2]) so as to make the
%   two halves the same size.  This notional range is not returned.  A
%   notional color map is imagined covering the notional range, using min,
%   mid, and max colours for min, mid, and max values; then the part of the
%   colour map is returned covering the the same range that is returned.
%
%   See also: standardizeColourDesc.

    if nargin < 4
        steps = 100;
    end
    
    colors = standardizeColourDesc( hues );
    if size(colors,1)==1
        colors = [ oppositecolor(colors); 1 1 1; colors ];
    elseif size(colors,1)==2
        colors = [ colors(1,:); 1 1 1; colors(2,:) ];
    elseif size(colors,1) > 3
        colors(4:end,:) = [];
    end
    negcolor = colors(1,:);
    zerocolor = colors(2,:);
    poscolor = colors(3,:);
    EXTENDEDRANGE = false;
    if EXTENDEDRANGE
        poscolors = [ zerocolor; ...
                      (2/3)*zerocolor + (1/3)*poscolor; ...
                      (1/3)*zerocolor + (2/3)*poscolor; ...
                      poscolor; ...
                      (2/3)*poscolor ];
        negcolors = [ (2/3)*negcolor; ...
                      negcolor; ...
                      (1/3)*zerocolor + (2/3)*negcolor; ...
                      (2/3)*zerocolor + (1/3)*negcolor; ...
                      zerocolor ];
    else
        poscolors = [ zerocolor; poscolor ];
        negcolors = [ zerocolor; negcolor ];
    end
    
    if (length(range)==2) || split
        range(3) = 0;
    end
    
    if split
        range = [ min(range([1 3])) max(range([2 3])) range(3) ];
    else
        range(3) = range(1);
    end

    if range(3)==range(1)
        cmap = makeCmap( poscolors, steps, 1 );
    elseif range(3)==range(2)
        cmap = makeCmap( negcolors( end:-1:1, : ), steps, 1 );
    else
        % Expand notional range to make positive and negative halves the
        % same size.
        cmap = posnegMap( range, negcolors, poscolors, steps );
    end
end
