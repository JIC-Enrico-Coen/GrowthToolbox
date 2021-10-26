function x = inh( k, m )
%x = inh( k, m )
% Calculate the inhibitory effect of morphogen m with scale factor k.
% The morphogen and the scale are forced to be non-negative.

    x = 1 ./ (1 + max(k,0) .* max(m,0));
end
