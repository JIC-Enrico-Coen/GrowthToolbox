function x = inh( k, m )
%x = inh( k, m )
% Calculate the inhibitory effect of morphogen m with scale factor k.
% The morphogen and the scale are forced to be non-negative.
% 
% x would be NaN if k were 0 and m infinite, or if m were 0 and k infinite.
% In this case, purely as a conventional measure, x is set to 0, i.e. the
% infinite part trumps the zero. A warning is printed.

    x = 1 ./ (1 + max(k,0) .* max(m,0));
    xnans = isnan(x);
    if any(xnans)
        fprintf( 1, 'WARNING: inh(0,Inf) or inh(Inf,0) is potentially undefined. %d occurrences of NaN set to 0.\n', ...
            sum(xnans) );
        x(xnans) = 0;
    end
end
