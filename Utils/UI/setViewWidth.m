function vp = setViewWidth( vp, viewWidth )
    vp.fov = 2*atan2( viewWidth/2, vp.camdistance )*180/pi;
end
