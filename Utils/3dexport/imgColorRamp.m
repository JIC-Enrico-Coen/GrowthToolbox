function img = imgColorRamp( sz )
%img = imgColorRamp()
%   Render the image encoded by colorFromRamp.

    u = linspace(0,1,sz+1);
    u(end) = [];
    u = u + 1/(2*sz);
    v = u;
    c = colorFromRamp( repmat( u(:), sz, 1 ), reshape( repmat( v, sz, 1 ), [], 1 ) );
    img = reshape(c,sz,sz,3);
end
