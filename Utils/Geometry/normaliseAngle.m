function a = normaliseAngle( a, mina, degrees, lowerClosed )
%a = normalizeAngle( a, mina, degrees, lowerClosed )
%   An integer multiple of one revolution is added to A as necessary to make
%   it fall in the range [mina...mina+onerevolution].  If lowerClosed is true
%   (the default), then the interval is [mina...mina+onerevolution), otherwise
%   (mina...mina+onerevolution].  If degrees is true (the default), then
%   the calculation is carried out in degrees, otherwise in radians.

    if nargin < 4
        lowerClosed = true;
    end
    if nargin < 3
        degrees = true;
    end
    if nargin < 2
        if degrees
            mina = -180;
        else
            mina = -pi;
        end
    end
    if degrees
        onerevolution = 360.0;
    else
        onerevolution = pi+pi;
    end
    maxa = mina + onerevolution;
    a = normaliseNumber( a, mina, maxa, lowerClosed );
    return;
%{
    for i=1:numel(a)
        b = a(i);
        if b==mina
            if ~lowerClosed
                b = maxa;
            end
        elseif b==maxa
            if lowerClosed
                b = mina;
            end
        elseif b < mina
            b = b + floor( (maxa-b)/onerevolution )*onerevolution;
        elseif b > maxa
            b = b - floor( (b - mina)/onerevolution )*onerevolution;
        end
        a(i) = b;
    end
%}
end
