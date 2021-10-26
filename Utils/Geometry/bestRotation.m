function [r,xc] = bestRotation( x, u )
%r = bestRotation( x, u )
%   Find the linear transformation of x that best approximates the
%   displacements u, and return its rotational component.
%   The method used here is only valid for small rotations.

    [m,t] = fitmat( x, x+u );
    rmat = (m - m')/2;
    if isempty(rmat)
        r = [0 0 0];
    elseif size(rmat,1)==2
        r = [ 0, 0, rmat(1,2) ];
    else
        r = [ rmat(2,3), rmat(3,1), rmat(1,2) ];
    end
    
    xc = sum(x,1)/size(x,1);
    
    % Check: when u was generated by a rotation, ur should equal u.
  % ur = cross( repmat(r,size(x,1),1), x, 2 )
  % u
  % uerr = u - ur
end
