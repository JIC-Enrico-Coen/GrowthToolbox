function [xx,yy,zz] = circle( varargin )
%[xx,yy,zz] = circle( varargin )
%   Similar to SPHERE, but draws a unit circle in the XY plane, or
%   returns the [xx,yy,zz] data for plotting with SURF.  The zz
%   result is always a zero matrix.
%
%   See also: SPHERE.

    narginchk(0,2);
    [cax,args,nargs] = axescheck(varargin{:});

    n = 20;
    if nargs > 0, n = args{1}; end
    theta = (-n:2:n)*pi/n;
    r = (0:n)'/n;
    costheta = cos(theta); costheta(1) = -1; costheta(n+1) = -1;
    sintheta = sin(theta); sintheta(1) = 0; sintheta(n+1) = 0;
    x = r*costheta;
    y = r*sintheta;
    z = zeros(size(x));

    if nargout == 0
        cax = newplot(cax);
        surf(x,y,z,'parent',cax);
    else
        xx = x; yy = y; zz = z;
    end
end
