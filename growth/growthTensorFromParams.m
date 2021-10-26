function gt = growthTensorFromParams( major, minor, theta )
    s = sin(theta);
    c = cos(theta);
    s2 = s*s;
    c2 = c*c;
    xx = major*c2 + minor*s2;
    yy = major*s2 + minor*c2;
    xy = (major-minor)*s*c;
    gt = [ xx; yy; 0; 0; 0; xy ];
  % fprintf( 1, 'rk-gTFP( %.3f %.3f %.3f ) = [ %.3f %.3f %.3f %.3f %.3f %.3f ]\n', ...
  %     major, minor, theta, gt );
end
