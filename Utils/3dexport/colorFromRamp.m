function c = colorFromRamp( u, v )
%c = colorFromRamp( x, y )
%   Map UV coordinates to the colors of a procedural texture consisting of
%   a two-dimensional colour ramp with a black and white chequered L in
%   the middle.

    c = [ u(:), v(:), (1-u(:)).*(1-v(:)) ];
    
    lx = [3 4 5]/8;
    ly = [2 3 6]/8;
    inl = (u >= lx(1)) & (u < lx(3)) & (v >= ly(1)) & (v < ly(3));
    inl = inl & ((u < lx(2)) | (v < ly(2)));
    c(inl,:) = repmat( mod( floor(u(inl)*16) + floor(v(inl)*16), 2 ), 1, 3 );
    
    gridintervals = 2;
    gridradius = 1/16;
    ug = u*gridintervals;
    ug = ug - round(ug);
    vg = v*gridintervals;
    vg = vg - round(vg);
    isgridpoint = (ug.^2 + vg.^2) <= gridradius.^2;
%     c(isgridpoint,:) = 1 - c(isgridpoint,:);
    value = double( (ug(isgridpoint)>=0) == (vg(isgridpoint)>=0) );
    c(isgridpoint,:) = repmat( value, 1, 3 );
end
