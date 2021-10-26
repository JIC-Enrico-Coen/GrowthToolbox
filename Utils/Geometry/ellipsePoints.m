function pts = ellipsePoints( xsemidiam, ysemidiam, numpts, theta0, theta1 )
%pts = ellipsePoints( a, b, n )
%   Return n equally spaced points along the positive quadrant of the
%   ellipse defined by x^2/a^2 + y^2/b^2 = 1. n defaults to 101.
%
%   The points start at [0,b] and end at [a,0].

    if nargin < 3
        numpts = 101;
    end
    
    if xsemidiam <= 0
        pts = [ zeros(numpts,1), linspace(ysemidiam,0,numpts)' ];
        return;
    elseif ysemidiam <= 0
        pts = [ linspace(0,xsemidiam,numpts)', zeros(numpts,1) ];
        return;
    end
    
    b = ysemidiam/xsemidiam;
    swap = b < 1;
    if swap
        b = 1/b;
    end
    
    trialnumpts = numpts*10;
    x0 = cos(theta0);
    x1 = cos(theta1);
    x = linspace(x0,x1,trialnumpts);
    y = b*sqrt(1-x.^2);
    xylengths = sqrt( (x(2:end) - x(1:(end-1))).^2 + (y(2:end) - y(1:(end-1))).^2 );
    approxlengths = [0 cumsum(xylengths)];
    exactlengths = linspace( 0, approxlengths(end), numpts );
    zz = interp( approxlengths, 1:trialnumpts, exactlengths(1:(end-1)) );
    zzi = floor(zz);
    zzf = zz - zzi;
    xx = [ x(zzi).*(1-zzf) + x(zzi+1).*zzf, x(end) ];
    yy = [ y(zzi).*(1-zzf) + y(zzi+1).*zzf, y(end) ];
    pts = [ xx(:), yy(:) ];
    return;
    
    
    
    
    
    
    
    
    
    
    b = ysemidiam/xsemidiam;
    swap = b < 1;
    if swap
        b = 1/b;
    end
    m = 1 - 1/b^2;
    u = ellipticK( m );
    dividedLength = linspace( 0, u, numpts );
    
    [sn,cn,dn] = ellipj( dividedLength, m );
    
    sd = sn./dn;
    cd = cn./dn;
    
    % the points (cd,sd) lie on the ellipse, but are not uniformly spaced.
    % There should be a way to directly calculate uniformly spaced points,
    % but I have not worked out what it is. Instead, we take these points
    % and correct them to uniform spacing.
    cdsdlengths = sqrt( (cd(2:end) - cd(1:(end-1))).^2 + (sd(2:end) - sd(1:(end-1))).^2 );
    approxlengths = [0 cumsum(cdsdlengths)];
    exactlengths = linspace( 0, approxlengths(end), numpts );
    
    zz = interp( approxlengths, 1:numpts, exactlengths(1:(end-1)) );
    zzi = floor(zz);
    zzf = zz - zzi;
    ssd = [ sd(zzi).*(1-zzf) + sd(zzi+1).*zzf, sd(end) ];
    ccd = [ cd(zzi).*(1-zzf) + cd(zzi+1).*zzf, cd(end) ];
    
    if swap
        pts = [ ssd(:), ccd(:) ] * ysemidiam;
    else
        pts = [ ccd(:), ssd(:) ] * xsemidiam;
    end
end
