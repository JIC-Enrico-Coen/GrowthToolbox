function p = randInCircle2( r, n )
%p = randInCircle2( r, n )
%   Select n points uniformly at random in a disc of radius r.

    if nargin < 2, n = 1; end
    randr = r*sqrt(rand(n,1));
    randa = pi*2*rand(n,1);
    p = [randr.*cos(randa),randr.*sin(randa)];
end
    