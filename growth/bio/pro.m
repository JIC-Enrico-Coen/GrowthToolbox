function x = pro( k, m )
%x = pro( k, m )
% Calculate the promoting effect of morphogen m with scale factor k.
% The morphogen and the scale are forced to be non-negative.

    x = 1 + max(k,0) .* max(m,0);
end
