function s = nums2string( x, fmt )
%s = nums2string( x, fmt )
%   Format a list of numbers to a string, using FMT as the format for each
%   number.

    s = [ '[', sprintf( [ ' ', fmt ], x ), ' ]' ];
end
