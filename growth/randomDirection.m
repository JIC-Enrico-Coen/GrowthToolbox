function d = randomDirection( t, n )
%d = randomDirection( t, n )
%   t is a 2-dimensional growth tensor.  Compute n random splitting directions
%    based on the tensor.
  % theta = (1:n) * 2 * pi / n;
    theta = rand(1,n) * 2 * pi;
    v = [ sin(theta); cos(theta) ];
    d = t*t*v;
    for i=1:n
        d(:,i) = d(:,i)/norm(d(:,i));
    end
end

