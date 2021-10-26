function cc = contrastColor( c )
%cc = contrastColor( c )
%   Find a colour that contrasts well with C, so that if either colour is
%   the background, the other can be used for text in the foreground.
%   This is a fairly crude algorithm: each RGB component is 0 or 1,
%   depending on which is further from that component of C.

%   NB.  It is mathematically impossible for this function to be
%   continuous: any continuous function on any colour space of any
%   dimensionality must have at least one fixed point.

    cc = zeros(size(c));
    cc(c <= 0.5) = 1;
end
