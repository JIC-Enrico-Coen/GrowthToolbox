function [theta,ax,rotmat] = vecangle( a, b, n )
%[theta,ax,rotmat] = vecangle( a, b, n )
%   Return the angle THETA between two row vectors, the axis about which a
%   rotation by THETA brings A to be parallel to B, and a rotation matrix
%   for that rotation.  The result satisfies that A*ROTMAT is parallel to
%   B.
%
%   If N is not supplied, THETA will always be in the range 0..pi. If N is
%   supplied then THETA will be in the range -pi..pi, with the sign
%   positive if the triple (A,B,N) is right-handed and negative if
%   left-handed. None of A, B, or N need be normalised but all must be
%   nonzero. Where any of them are zero the results wiil be all zero, but
%   these will not be meaningful values. Since a meaningful value for AX is
%   always non-zero, checking this will determine if the results are
%   meaningful.
%
%   Any or all of A, B, and N can instead be K*3 matrices. Any that are 1*3
%   vectors will be replicated to K*3. THETA will then be a K*1 vector of
%   angles.

    if size(a,2)==2
        a = [a,zeros(size(a,1),1)];
    end
    if size(b,2)==2
        b = [b,zeros(size(b,1),1)];
    end
    if (size(a,1)==1) && (size(b,1) > 1)
        a = repmat( a, size(b,1), 1 );
    end
    if (size(b,1)==1) && (size(a,1) > 1)
        b = repmat( b, size(a,1), 1 );
    end
    c = dotproc2(a,b);
    ax = crossproc2(a,b);
    s = sqrt( sum( ax.^2, 2 ) );
    if nargin >= 3
        s = s .* sign( dotproc2( ax, n ) );
    end
    theta = atan2( s, c );
    ok_s = s ~= 0;
    ax = ax./repmat(s,1,size(ax,2));
    ax(~ok_s,:) = 0;
    
    if nargout >= 3
        theta = permute( theta, [2 3 1] );
        ct = cos(theta);
        ct1 = 1-ct;
        st = sin(theta);
        ux = ax(1);
        uy = ax(2);
        uz = ax(3);
        uxyct1 = ux*uy*ct1;
        uzst = uz*st;
        uzxct1 = uz*ux*ct1;
        uyst = uy*st;
        uyzct1 = uy*uz*ct1;
        uxst = ux*st;
        rotmat = [ ct + ux^2*ct1, uxyct1 - uzst, uzxct1 + uyst;
                   uxyct1 + uzst, ct + uy^2*ct1, uyzct1 - uxst;
                   uzxct1 - uyst, uyzct1 + uxst, ct + uz^2*ct1 ];
        rotmat(:,:,~ok_s) = 0;
    end
end
