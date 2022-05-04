function w = findPerpVector( v, trial )
%w = findPerpVector( v )  Returns a unit vector perpendicular to v.
%   v can be a row vector of length 3 or an N*3 matrix of row vectors.
%
%   If v is all zero, the result is all zero.
%   Otherwise, w is the normalised crossproduct of v and [1 0 0], if this
%   is nonzero.  Otherwise, the normalised crossproduct of v and [0 1 0].

    haveTrial = nargin >= 2;
    if haveTrial
        trial = crossproc2(v,trial);
    end
    w = zeros(size(v));
    for i=1:size(v,1)
        if all(v(i,:)==0)
            w(i,:) = [ 0, 0, 0 ];
        else
            ok = false;
            if haveTrial
                u = trial(i,:);
                w(i,:) = crossproc2( v(i,:), u );
                ok = any(w(i,:) ~= 0);
            end
            if ~ok
                u = [ 1, 0, 0 ];
                w(i,:) = crossproc2( v(i,:), u );
                ok = any(w(i,:) ~= 0);
            end
            if ~ok
                u = [ 0, 1, 0 ];
                w(i,:) = crossproc2( v(i,:), u );
            end
        end
    end
    w = normvecs(w);
end
