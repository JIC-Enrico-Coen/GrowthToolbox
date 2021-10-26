function a = extendHeight( a, extra )
%a = extendHeight( a, extra )
%   Add extra zero rows to an array.

    extrasize = size(a);
    extrasize(1) = extra;
    a = [ a; zeros( extrasize ) ];
end
