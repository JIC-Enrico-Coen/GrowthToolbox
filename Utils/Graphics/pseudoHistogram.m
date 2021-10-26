function xy = pseudoHistogram( x, halfwidth, varargin )
%y = pseudoHistogram( x, halfwidth, ... )
%   This produces a histogram-like plot of the values X. X may have any
%   shape.
%
%   Each value x is represented as a function which is 1 on the interval
%   [x-HALFWIDTH,x+HALFWIDTH]. These functions are then summed. The
%   result XY is a 2N*2 array, where N is the number of elements of X.
%   XY(:,1) contains all of the values in X-HALFWIDTH and X+HALFWIDTH in
%   ascending order. XY(:,2) is the cumulative sum of the values +1 for
%   each value in X-HALFWIDTH and -1 for each value in X+HALFWIDTH,
%   normalised so that the total area under the graph is equal to the
%   number of values in X.
%
%   If no output is asked for then the resulting values are plotted.
%   Arguments after the HALFWIDTH argument are passed to plot().
%   Otherwise XY is returned and no plotting is done.

    x = reshape( x, [], 1 );
    xlo = x-halfwidth;
    xhi = x+halfwidth;
    z = sortrows( [ [xlo; xhi], [ ones( length(x), 1 ); -ones( length(x), 1 ) ] ] );
    x1 = z(:,1);
    y1 = cumsum( z(:,2) );
    area = sum( (z(2:end,1) - z(1:(end-1),1)) .* (y1(2:end) + y1(1:(end-1))) )/2;
    y1 = y1*(length(x)/area);
    xy = [x1, y1];
    
    if nargout==0
        plot(x1,y1,varargin{:});
    end
end