function s = mixstrings( s1, s2 )
%s = mixstrings( s1, s2 )
%   Convert the character strings s1 and s2 to double, take the bitwise
%   xor, and convert the result back to a character string. s2 must be at
%   least as long as s1; any characters beyond the length of s1 are
%   ignored.
%
%   The purpose of this is to provide a scrambled version of s1.
%
%   THIS IS NOT A CRYPTOGRAPHIC TRANSFORMATION! DO NOT USE IT TO CONCEAL
%   THE VALUE OF S1!

    s = char( bitxor( double(s1), double(s2(1:length(s1))) ) );
end
