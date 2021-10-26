function len = ellipseArcLength( xsemidiam, ysemidiam, theta1, theta2 )
    swaptheta = theta1 > theta2;
    if swaptheta
        temp = theta1;
        theta1 = theta2; theta2 = temp;
    end
    b = ysemidiam/xsemidiam;
    swapaxes = b < 1;
    if swapaxes
        b = 1/b;
        temp = theta1;
        theta1 = pi/2 - theta2;
        theta2 = pi/2 - temp;
    end
    m = 1 - 1/b^2;
    if swapaxes
        theta1 = pi/2-theta1;
        theta2 = pi/2-theta2;
    end
    len = eal( theta2, m ) - eal( theta1, m );
    if swaptheta
        len = -len;
    end
    if swapaxes
        len = len * ysemidiam;
    else
        len = len * xsemidiam;
    end
    
    x1 = xsemidiam*cos(theta1);
    y1 = ysemidiam*cos(theta1);
    x2 = xsemidiam*cos(theta2);
    y2 = ysemidiam*cos(theta2);
    lenxy = sqrt( (x2-x1)^2 + (y2-y1)^2 )
end

function z = eal( theta, m )
    if false
        z = ellipticF( theta, m );
    elseif true
        z = ellipticE( theta, m );
    else
        z = ellipticE( theta, m ) - m^2 * sin(theta) * cos(theta)/sqrt(1 - m^2 * sin(theta)^2);
    end
end
