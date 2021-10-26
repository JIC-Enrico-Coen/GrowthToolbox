function c = subtractiveMix( a, s )
%c = subtractiveMix( a, s )
%   s is a parameter >= 0 and < 1.
%   a is a array whose last dimension indexes the colour channels, and
%   whose next-to-last dimension indexes the colours to be mixed.

    asz = size(a);
    cdim = length(asz);
    numchannels = asz(end);
    mdim = cdim-1;
    min_a = min( a, [], cdim );  % The minimum of the colour channels of a.
    a = 1 - (1-a)*(1-s);
    c = reshape( prod( a, mdim ), [], numchannels );  % c is the product of all the colours.
    want_min_c = reshape( prod( min_a, mdim ), [], 1 );  % want_min_c is product of the channel minimums.
    min_c = reshape( min( c, [], 2 ), [], 1 );  % min_c is the minimum of the colour channels of c.
    adjustneeded = (min_c < 1) & (min_c > want_min_c);
    if any(adjustneeded)
        adjustments = (1-want_min_c(adjustneeded))./(1-min_c(adjustneeded));
        for i=1:3
            c(adjustneeded,i) = 1 - (1 - c(adjustneeded,i)) .* adjustments;
        end
    end
    if cdim > 2
        c = reshape( c, asz( [1:(end-2) end] ) );
    end
end

function m = mix2( a, s )
    cdim = length(size(a));
    mdim = cdim-1;
    if s==0
        m = min( a, [], mdim );
    elseif s==1
        m = mean( a, mdim );
    else
        min_a = min( a, [], mdim );
        mean_a = mean( a, mdim );
        m = (1-s)*min_a + s*mean_a;
    end
end
