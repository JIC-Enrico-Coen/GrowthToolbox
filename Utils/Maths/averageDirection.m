function v = averageDirection( vectors, weights, normal )
%v = averageDirection( vectors, weights, normal )
%   VECTORS is an N*3 matrix of unit row vectors.
%   WEIGHTS is a vector of N weights summing to 1.
%   The result is a unit vector whose direction is in some sense the
%   weighted average of the directions of the given vectors.  It is
%   constrained to be perpendicular to NORMAL, and the given vectors are
%   expected to be at least approximately perpendicular to NORMAL.  If
%   NORMAL is not supplied, it defaults to [0 0 1].
%
%   There is no continuous averaging operation in the space of unit
%   vectors.  Therefore, this function is discontinuous.  There is more
%   than one plausible candidate for the "average".  The one we implement
%   is to take the weighted average of the vectors, project it perpendicular
%   to NORMAL, then normalise it to unit length.  If the projection of the
%   average is zero, a random perpendicular to NORMAL is returned.  An
%   alternative method is to choose the direction that minimises the
%   second moment of the distribution of the directions around that value.
%   An implementation of that is available in the code below, but only for
%   the case where NORMAL is [0 0 1].

    if nargin < 3
        normal = [0 0 1];
    end
    AVERAGEVECTORS = true;
    RANDOMAMOUNT = 0;
    if AVERAGEVECTORS
        alph = 1;
        v = weights * vectors;
        v = v + (rand(size(v))-0.5)*RANDOMAMOUNT;
        v = makeperp( normal, v );
        vn = norm(v);
        if vn > 0
            v = v * (1 - alph + alph/vn);
        else
          % v = zeros(1,size(vectors,2));
            v = randperp( normal );
        end
    else
        % This method assumes NORMAL is [0 0 1].
        angles = atan2(vectors(:,2),vectors(:,1))';
        a = averageAngle( angles, weights ) + (rand(1)*2-1)*0;
        v = [cos(a),sin(a),0];
    end
end
