function [x,y] = selectPLC( distrib, n )
    [x,d] = invdistrib( distrib, rand(n,1) );
    y = rand(n,1).*d;
end
