function a = arithprog( first, last, n )
%a = arithprog( first, last, n )
%   Return an array of n integers, beginning with FIRST and ending with
%   LAST, and being as equally spaced as possible between,

    a = round( linspace( first, last, n ) );
end
