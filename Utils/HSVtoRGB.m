function rgb = HSVtoRGB( h, s, b )
%rgb = HSVtoRGB( h, s, b )
%   Better version of hsv2rgb that allows any real number as a value of h,
%   and trims s and b to the range 0..1.

    if nargin==1
        b = h(:,3);
        s = h(:,2);
        h = h(:,1);
    else
        if numel(s)==1
            s = s*ones(size(h));
        end
        if numel(b)==1
            b = b*ones(size(h));
        end
    end
    h = mod(h,1);
    s = trimnumber( 0, s, 1 );
    b = trimnumber( 0, b, 1 );
    h6 = h*6;
    hs = floor(h6);
    huefraction = h6 - hs;
    p = b .* (1 - s);
    q = b .* (1 - huefraction.*s);
    t = b .* (1 - (1-huefraction).*s);
    rgb = zeros( length(h), 3 );
    if any(hs==0), rgb(hs==0,:) = [ b(hs==0) t(hs==0) p(hs==0) ]; end
    if any(hs==1), rgb(hs==1,:) = [ q(hs==1) b(hs==1) p(hs==1) ]; end
    if any(hs==2), rgb(hs==2,:) = [ p(hs==2) b(hs==2) t(hs==2) ]; end
    if any(hs==3), rgb(hs==3,:) = [ p(hs==3) q(hs==3) b(hs==3) ]; end
    if any(hs==4), rgb(hs==4,:) = [ t(hs==4) p(hs==4) b(hs==4) ]; end
    if any(hs==5), rgb(hs==5,:) = [ b(hs==5) p(hs==5) q(hs==5) ]; end
end

