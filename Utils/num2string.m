function s = num2string( n, decpl )
%s = num2string( n, decpl )
%   Convert the number n to a string without unnecessary zeroes or decimal
%   points.  decpl (default 6) is the maximum number of decimal places to
%   allow.

    if nargin < 2
        decpl = 6;
    end
    s = sprintf( '%.*f', decpl, n );
    s = regexprep( s, '0*$', '' );
    s = regexprep( s, '\.$', '' );
end
