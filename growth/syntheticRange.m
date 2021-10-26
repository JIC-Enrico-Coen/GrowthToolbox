function result = syntheticRange( r, zeroscaling )
%r1 = syntheticRange( r, zscaling )
%   r is the range of some value to be plotted, i.e. its maximum absolute
%   value.  r1 is the range to be used for its color scale.  r1 will be
%   equal to r when r is >= 1, but otherwise will tend to zeroscaling*r
%   as r approaches zero. zeroscaling will typically be greater than 1,
%   perhaps around 2.5 according to taste.
%
%   The idea behind this is that if we are plotting using a two-color scale
%   whose bounds are fixed at +/- 1, then if the actual values to be
%   plotted are all very small in magnitude, then the plot will just look a
%   uniform white, or with just slight hints of color. However, if the
%   color scale is fitted to the range present, then the fully saturated
%   colours that result will give a misleading idea of how large the values
%   are.  We therefore want to reduce the range to some multiple of the
%   range present, so that the colours will be less saturated than with
%   automatic bounds, but more visible than with fixed bounds.
%
%   In order to get simple values for the ends of the color bar, r1 is also
%   rounded up to have exactly 1 significant figure.

    maxval = max(r);
    minval = min(r);
    maxabsval = max(abs([minval maxval]));

    if (maxabsval >= 1) || (zeroscaling==1)
        newmaxabsval = maxval;
    elseif maxabsval == 0
        newmaxabsval = 1;
    else
        scaling = max( 1, maxabsval + zeroscaling*(1-maxabsval) );
        newmaxabsval = scaling*maxabsval;
        x = round( newmaxabsval, 1, 'significant' );
        if x < newmaxabsval
            % Round up.
            x = x + 10^(floor(log10(x)));
        end
        newmaxabsval = x;
    end
    
    if minval < 0
        if maxval > 0
            result = [-newmaxabsval newmaxabsval];
        else
            result = [-newmaxabsval 0];
        end
    elseif maxval > 0
        result = [0 newmaxabsval];
    else
        result = [minval, maxval];
    end
end
