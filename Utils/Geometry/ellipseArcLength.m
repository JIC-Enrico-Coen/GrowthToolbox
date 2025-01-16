function len = ellipseArcLength( xsemidiam, ysemidiam, theta1, theta2 )
%len = ellipseArcLength( xsemidiam, ysemidiam, theta1, theta2 )
%   Calculate the length of an elliptical arc. The semi-axes are xsemidiam
%   and ysemidiam. theta1 and theta2 are the angles specifyin ghte
%   endpoints of the ellipse, if the ellipse were stretched to a circle.
%   That is, the point specified by an angle theta is
%   [ xsemidiam*cos(theta), ysemidiam*theta) ]. The result is a signed real
%   number, and if theta1 and theta2 differ by more than 2*pi, the answer
%   will include correspondingly many whole perimeters of the ellipse.
%
%   If only theta1 is given the arc length from  0 to theta is calculated.
%
%   The four arguments can be of any consistent shapes.
%
%   Negative semi-diameters are treated as positive.
%
%   The calculation is made using Matlab's built-in elliptic function
%   ellipticE.
%
%   See also: ellipticE

    if nargin < 4
        theta2 = theta1;
        theta1(:) = 0;
    end
    
    try
        [xsemidiam, ysemidiam, theta1, theta2] = reconcileArrays( xsemidiam, ysemidiam, theta1, theta2 );
    catch e
        throw( e );
    end
    
    xsemidiam = abs(xsemidiam);
    ysemidiam = abs(ysemidiam);
    xsemidiam = xsemidiam + zeros( size( ysemidiam ) );
    ysemidiam = ysemidiam + zeros( size( xsemidiam ) );
    swapxy = ysemidiam > xsemidiam;
    if any(swapxy(:))
        temp = xsemidiam(swapxy);
        xsemidiam(swapxy) = ysemidiam(swapxy);
        ysemidiam(swapxy) = temp;
        temp = theta1(swapxy);
        theta1(swapxy) = pi/2 - theta2(swapxy);
        theta2(swapxy) = pi/2 - temp;
    end
    r = ysemidiam./xsemidiam;

    % Compute the square of the modulus k for the Jacobi elliptic functions.
    ksq = 1 - r.^2;

    len = xsemidiam .* (ellipticE( theta2, ksq ) - ellipticE( theta1, ksq ));

    % Ramanujan gave approximate formulas for the arc length of the whole
    % ellipse. Two of these are calculated and compared here.
%         lenR1 = pi * (3*(xsemidiam+ysemidiam) - sqrt( (3*xsemidiam+ysemidiam)*(xsemidiam+3*ysemidiam) ))
%         lambda = (xsemidiam - ysemidiam)/(xsemidiam + ysemidiam);
%         lenR2 = pi * (xsemidiam+ysemidiam) * (1 + 3*lambda^2/(10 + sqrt( 4 - 3*lambda^2 )))
%         diff1 = len-lenR1
%         diff2 = len-lenR2
%         diff12 = lenR1-lenR2
    xxxx = 1;
    
    len( (xsemidiam==0) & (ysemidiam==0) ) = 0;
end

function varargout = reconcileArrays( varargin )
    sz = [];
    for vi=1:length(varargin)
        sz1 = size(varargin{vi});
        if length(sz) < length(sz1)
            sz((end+1):length(sz1)) = sz1((length(sz)+1):length(sz1));
        elseif length(sz1) < length(sz)
            sz1((end+1):length(sz1)) = sz((length(sz1)+1):length(sz1));
        end
        sz = max( sz, sz1 );
    end
    zz = zeros( sz );
    varargout = cell( 1, length(varargin) );
    for vi=1:length(varargin)
        varargout{vi} = varargin{vi} + zz;
    end
end
