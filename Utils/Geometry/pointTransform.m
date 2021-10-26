function [mx,n] = pointTransform( v1, v2, w1, w2, n )
% Calculate a 3*2 matrix describing an affine transformation mapping v1 to
% w1 and v2 to w2. The transformation must consist of translation, scaling,
% and rotation only.
% Given a N*2 array of points n, the new value of n should be
% [n,ones(size(n,1),1)]*mx)[:,1:2].

    dv = v2-v1;
    dw = w2-w1;
    av = atan2( dv(2), dv(1) );
    aw = atan2( dw(2), dw(1) );
    rotangle = aw-av;
    dilation = norm(dw)/norm(dv);
    cra = cos(rotangle);
    sra = sin(rotangle);
    dilrotmx = dilation*[ [cra, sra]; [-sra, cra] ];
    mx = [ dilrotmx; w1 - v1*dilrotmx ];
    if nargin >= 5
        nr = [n(:,1:2),ones(size(n,1),1)]*mx;
        n = [ nr(:,1:2), n(:,3) ];
    end
end
