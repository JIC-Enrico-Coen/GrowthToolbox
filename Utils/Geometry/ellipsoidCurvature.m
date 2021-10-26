function c = ellipsoidCurvature( c1, c2, angle )
    c = c1.*cos(angle).^2 + c2.*sin(angle).^2;
end
