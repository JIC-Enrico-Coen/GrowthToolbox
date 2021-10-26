function a = interpolateAngle( a0, a1, fraction )
    d = clipAngleDeg( a1-a0, -180 );
    a = clipAngleDeg( a0 + d*fraction, -180 );
end

