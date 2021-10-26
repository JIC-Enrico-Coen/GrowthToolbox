function cmap = colorStep( c1, c2, n, open1, open2 )
%cmap = colorStep( c1, c2, n, open1, open2 )
%   Construct a colour map with n elements, going from c1 to c2.
%   If open1 is true, the first value will be omitted.
%   If open2 is true, the last value will be omitted.
%   open1 and open2 default to false.

    if nargin < 4, open1 = false; end
    if nargin < 5, open2 = false; end
    cmap = [ step( c1(1), c2(1), n, open1, open2 ); ...
             step( c1(2), c2(2), n, open1, open2 ); ...
             step( c1(3), c2(3), n, open1, open2 ) ]';
end
 
