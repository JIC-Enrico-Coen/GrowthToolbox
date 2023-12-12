function b = fadeCurve( a, method )
%b = fadeCurve( a )
%   This defines a function mapping 0...1 to 0...1, intended as a smooth
%   interpolation function.
%
%   METHOD specifies the interpolation curve to use. It defaults to
%   'cosine'. Possible values are:
%
%   'linear'    b = a
%
%   'cosine'    b = (1 - cos( a*pi ))/2

    if nargin < 2
        method = 'cosine';
    end
    a = trimnumber( 0, a, 1 );
    switch method
        case 'cosine'
            b = (1 - cos( a*pi ))/2;
        otherwise
            b = a;
    end
end
