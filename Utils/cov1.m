function [c,d] = cov1( x )
    tic;
    n = size(x,1);
    xbar = sum(x,1)/n;
    c = (x'*x - n*xbar'*xbar)/(n-1);
    toc;
    
    tic;
    xsumsq = zeros( size(x,2) );
    xsum = zeros( 1, size(x,2) );
    [xsumsq,xsum] = accumulateCov( xsumsq, xsum, x );
    d = (xsumsq - xsum'*xsum/n)/(n-1);
    toc;
    
    tic;
    xsumsq = zeros( size(x,2) );
    xsum = zeros( 1, size(x,2) );
    for i=1:size(x,1)
        [xsumsq,xsum] = accumulateCov( xsumsq, xsum, x(i,:) );
    end
    d = (xsumsq - xsum'*xsum/n)/(n-1);
    toc;
end

function [xsumsq, xsum] = accumulateCov( xsumsq, xsum, x )
    xsumsq = xsumsq + x'*x;
    xsum = xsum + sum(x,1);
end