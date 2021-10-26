function [a,b] = ab_from_kbend( k, bend, allownegative )
%[a,b] = ab_from_kbend( k, bend )
%   Given growth K and bending BEND, compute the equivalent surface
%   growths A and B, such that K-BEND = A and K+BEND = B.
%   If allownegative is false, A and B are forced to be nonnegative, at the
%   expense of violating the equalities.  The default is that negative
%   values are allowed.
%
%   The K/BEND system is obsolete and no longer supported.  All new meshes
%   are created with A/B morphogens, and all old meshes using K/BEND are
%   automatically converted by upgrademesh() to A/B on loading.
%
%   See also: kbend_from_ab, convertKBENDtoAB.

    if nargin < 3
        allownegative = true;
    end
    a = k - bend;
    b = k + bend;
    if ~allownegative
        a = max(a,0);
        b = max(b,0);
    end
end
