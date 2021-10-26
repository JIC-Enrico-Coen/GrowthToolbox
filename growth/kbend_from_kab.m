function [k,bend] = kbend_from_kab( k, a, b )
%[k,bend] = kbend_from_kab( k, a, b )
%   Given general growth K and surface factors A and B, where the growth on
%   side A is K*A and the growth on side B is K*B, compute the equivalent
%   growth and bend factors K1 and BEND, such that K1-BEND = K*A and
%   K1+BEND = K*B.

    aabs = k .* a;
    babs = k .* b;
    k = (aabs + babs)/2;
    bend = (babs - aabs)/2;
end
