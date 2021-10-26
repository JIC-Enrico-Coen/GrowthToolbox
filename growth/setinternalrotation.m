function m = setinternalrotation( m, angle )
%m = setinternalrotation( m, angle )

    angle = normaliseAngle( angle, -pi, false );
    if m.globalProps.internallyrotated
        if angle ~= m.globalProps.totalinternalrotation
            m = rotatemesh( m, angle - m.globalProps.totalinternalrotation, 'Z' );
            m.globalProps.totalinternalrotation = angle;
        end
    else
        m.globalProps.totalinternalrotation = angle;
        if m.globalProps.totalinternalrotation ~= 0
            m = rotatemesh( m, m.globalProps.totalinternalrotation, 'Z' );
        end
        m.globalProps.internallyrotated = true;
    end
end
