function [c,vrange] = translateToColors( v, vrange, cmap, negcmap, normaliseInf )
%c = translateToColors( v, vrange, cmap, negcmap )
% Given a vector of values v, a range vrange = [lo,hi], and a list of
% colours, map every element of v to the corresponding colour.
% v is N*1, and c is N*3.
%
% If negcmap is given and is nonempty, then cmap is used for non-negative
% values, and negcmap for negative values. Negcmap is assumed to begin with
% the colour for zero and end with the colour for the most negative value
% represented.
%
% If cmap is empty, return all white.  If cmap is nonempty, and either
% vrange has at most one member or its second is <= its first, return
% copies of the first color in cmap.

    if (nargin >= 4) && ~isempty(negcmap)
        % Split color map.
        % If fewer than two colors are specified for either half, white is
        % added to represent zero.
        if size( cmap, 1 ) <= 1
            cmap = [ 1 1 1; cmap ];
        end
        if size( negcmap, 1 ) <= 1
            negcmap = [ 1 1 1; negcmap ];
        end
        c = zeros( length(v), size(cmap,2) );
        negvals = v < 0;
        if isempty(vrange)
            vrange = [ min(v), max(v) ];
            vrange(1) = min( vrange(1), 0 );
            vrange(2) = max( vrange(2), 0 );
        end
        c(negvals,:) = translateToColors( v(negvals), [vrange(1), 0], negcmap(end:-1:1,:) );
        c(~negvals,:) = translateToColors( v(~negvals), [0 vrange(2)], cmap );
        return;
    end
    
    numcolors = size(cmap,1);
    if numcolors==0
        % Cmap is empty.  Return all white.
        c = ones( length(v), 3 );
    elseif (length(vrange) <= 1) || (vrange(2) <= vrange(1))
        % Cmap is nonempty and vrange has at most one member.  Return
        % copies of the first color in cmap.
        c = repmat( cmap(1,:), length(v), 1 );
    else
        % General case.  Interpolate all of v into the color map.
        numchannels = size(cmap,2);
        cfracscaled = 1 + (v-vrange(1))*((numcolors-1)/(vrange(2)-vrange(1)));
        cindexlo = floor(cfracscaled);
        cremainder = cfracscaled - cindexlo;
        cremainder(isnan(cremainder)) = 0;
        cindexhi = cindexlo+1;
        cindexlo = min(max(cindexlo,1),numcolors);
        cindexhi = min(max(cindexhi,1),numcolors);
        mixing = repmat(cremainder,1,numchannels);
        c = cmap(cindexlo,:).*(1-mixing) ...
            + cmap(cindexhi,:).*mixing;
    end
end
