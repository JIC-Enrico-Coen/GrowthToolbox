function h = scatterPosNeg( ax, points, weights, scale )
%h = scatterPosNeg( points, weights, scale )
%h = scatterPosNeg( ax, points, weights, scale )
%   Use Matlab's scatter/scatter3 functions to plot a set of points which
%   may have positive or negative weights.  Positive points are plotted in
%   green, negative in red.  Each point is plotted as a solid circle whose
%   area is proportional to the absolute value of its weight.  (Thus points
%   of zero weight are not plotted at all.)  The points are added to the
%   current contents of the axes.  In a 2D plot, when blobs overlap,
%   positive overlays negative.
%
%   Axes default to the current axes.  Points is N*1, N*2 or N*3.  Weights
%   are real numbers, one for each point.  Scale is the maximum size of a
%   point; the area of blob drawn at each point will be proportional to the
%   absolute value of its weight.
%
%   The result is a pair of graphics handles of type hggroup.  These have
%   as children all the patch objects for the positively and negatively
%   weighted points respectively.
%
%   See also: scatter, scatter3.
%
%   Example:
%
%       h = scatterPosNeg( randn(100,2), randn(100,1), 200 );

    if nargin < 3
        error( 'Not enough arguments (%d found, 3 or 4 expected).', ...
               nargin );
    end
    if nargin==3
        scale = weights;
        weights = points;
        points = ax;
        ax = gca;
    end
    if size(points,2)==1
        points = [ points, zeros(size(points)) ];
    end
    
    posweights = weights > 0;
    negweights = weights < 0;
    maxweight = max(abs(weights));
    poscolor = [0 0.9 0.3];
    negcolor = 'r';
    posscales = (scale/maxweight)*weights(posweights);
    negscales = (-scale/maxweight)*weights(negweights);

    oldhold = get( ax, 'NextPlot' );
    hold(ax,'on');
    if size(points,2)==2
        hneg = scatter( ax, points(negweights,1), points(negweights,2), ...
                  negscales, negcolor, 'MarkerFaceColor', negcolor );
        hpos = scatter( ax, points(posweights,1), points(posweights,2), ...
                  posscales, poscolor, 'MarkerFaceColor', poscolor );
    else
        hneg = scatter3( ax, points(negweights,1), points(negweights,2), points(negweights,3), ...
                  negscales, negcolor, 'MarkerFaceColor', negcolor );
        hpos = scatter3( ax, points(posweights,1), points(posweights,2), points(posweights,3), ...
                  posscales, poscolor, 'MarkerFaceColor', poscolor );
    end
    set( ax, 'NextPlot', oldhold );

    h = [ hpos; hneg ];
end
