function w = findperp( v, trialvec )
%w = findperp( v )
%   Find a 3-element vector perpendicular to the 3-element vector v.  In
%   general the result will not be a unit vector, even if v is.
%   v must be a row vector or N*3 array of N row vectors.  w will be the
%   same shape as v.
%
%w = findperp( v, trialvec )
%   As findperp( v ), but w will be chosen to be in the same plane as
%   trialvec.

    if nargin > 1
        w = trialvec - v * (dot(trialvec,v)/sum(v.^2));
%         w = cross(v,trialvec);
        if norm(w) > 0
            return;
        end
    end
    
    w = zeros(size(v));
    for i=1:size(v,1)
        if v(i,1)==0
            w(i,:) = [ 0, -v(i,3), v(i,2) ];
        else
            w(i,:) = [ -v(i,2), v(i,1), 0 ];
        end
    end
end
