function [k,bend] = kbend_from_ab( a, b, allownegative )
%[k,bend] = kbend_from_ab( a, b )
%   Given surface growth A and B, compute the equivalent
%   growth and bend factors K and BEND, such that K-BEND = A and
%   K+BEND = B.  If ALLOWNEGATIVE is false, force K to be non-negative, at
%   the expense of violating these equalities.
%
%   The K/BEND system is obsolete and no longer supported.
%
%   See also: ab_from_kbend, convertKBENDtoAB.

    if nargin < 3
        allownegative = true;
    end
    k = (a+b)/2;
    bend = (b-a)/2;
    if ~allownegative
        k = max(k,0);
    end
end
