function [numtall,numwide] = arrangeSubplots( n )
%[numtall,numwide] = arrangeSubplots( n )
%   Given a number of subplots, decide how many rows and how many columns
%   to use. The results are suitable as the first two arguments to subplot.

    numwide = ceil(sqrt(n));
    numtall = ceil(n/numwide);
    numwide = ceil(n/numtall);
    switch n
        case 3
            numtall = 1;
            numwide = 3;
        case {7,8}
            numtall = 2;
            numwide = ceil(n/numtall);
    end    
end