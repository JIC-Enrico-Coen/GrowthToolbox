function dx = fixedJitter( y, tol, delta, maxjitter )
    dx = zeros( size(y) );
    [y1,p] = sort(y(:));
    yclose = [ false; y1(2:end) - y1(1:(end-1)) <= tol; false];
    ystarts = find( yclose(2:end) & ~yclose(1:(end-1)) );
    yends = find( yclose(1:(end-1)) & ~yclose(2:end) );
    runlengths = yends-ystarts+1;
    if nargin < 3
        scales = ones( size(runlengths) );
    else
        scales = (runlengths-1) * delta/2;
    end
    scales = min( scales, maxjitter );
    for i=1:length(runlengths)
        foo = linspace( -scales(i), scales(i), runlengths(i) );
        dx( ystarts(i):yends(i) ) = foo( randperm( length(foo) ) );
    end
    dx(p) = dx;
end
