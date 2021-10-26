function x = in_lin( k, m )
%x = in_lin( k, m )
% Calculate the inhibitory effect of morphogen m with scale factor k.

    x = max(0,1 - k*m);
end
