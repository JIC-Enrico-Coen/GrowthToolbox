function ca = circularAverage( angles, weights, cyclelength )
    [angles,perm] = sort(angles);
    weights = weights(perm);
    xangles = [ angles, angles(1)+cyclelength ];
    da = xangles(2:end) - angles;
    [~,ai] = max( da );
    voidval = (xangles(ai)+xangles(ai+1))/2;
    rectifiedangles = mod( angles - voidval, cyclelength ) - cyclelength/2;
    ca = mod( mean( rectifiedangles.*weights ) + voidval + cyclelength/2, cyclelength );
end

