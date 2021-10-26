function [g,v,d] = estimateGrowth( oldpts, newpts )
%g = estimateGrowth( oldpts, newpts )
%   oldpts and newpts are N*K matrices (with N > K) containing two sets of
%   N points in K dimensions.
%   estimateGrowth calculates the best-fit growth tensor that will grow
%   oldpts into the shape of newpts in one time unit.  Its eigenvectors and
%   eigenvalues are returned as the column matrix v and the columnvector d.
%   g is returned in the frame of reference of newpts, i.e. the best-fit
%   linear transformation of oldpts to newpts is decomposed into g*q where
%   q is a rotation and g is symmetric.  This is either the left or right
%   polar decomposition.
%
%   g and v will be K*K symmetric matrices, and d will be a K*1 vector. 
%
%   oldpts and newpts can be N*K*M matrices, in which case
%   g and v will be K*K*M and d will be K*M.

    if size(oldpts,3) == 1
        l = fitmat( oldpts, newpts );
        q = extractRotation( l );
        g = l*q';
        [v,d] = eig(g);
        % d = log(diag(d));
        d = diag(d)-1;
        g = v*diag(d)*v';
    else
        N = size(oldpts,1);
        K = size(oldpts,2);
        M = size(oldpts,3);
        g = zeros( K, K, M );
        v = zeros( K, K, M );
        d = zeros( K, M );
        for i=1:size(oldpts,3)
            l = fitmat( oldpts(:,:,i), newpts(:,:,i) );
            q = extractRotation( l );
            g1 = l*q';
            try
                [v1,d1] = eig(g1);
                % d1 = log(diag(d1));
                d1 = diag(d1)-1;
                g1 = v1*diag(d1)*v1';
                v(:,:,i) = v1;
                d(:,i) = d1;
            catch e
                fprintf( 1, 'Problem with FE %d:\n    %s\n', i, e.message );
                g1
            end
            g(:,:,i) = g1;
        end
    end
end
