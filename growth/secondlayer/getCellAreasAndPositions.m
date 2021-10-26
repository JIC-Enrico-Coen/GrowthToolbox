function [centroids, areas, projections] = getCellAreasAndPositions( m, varargin )
%[centroids, areas, projections] = getCellAreasAndPositions( m, ... )
%   The options are the same as for leaf_countBioCells, plus an additional
%   one, 'axis'.  'axis' is a vector, by default [1 0 0].
%
%   For all of the biological cells picked out by the options to
%   leaf_countBioCells, calculate the projections of their centroids on the
%   specified axis.
%
%   See also: leaf_countBioCells

    % Set all the results in case of early return.
    centroids = [];
    areas = [];
    projections = [];
    
    % Check the arguments.
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'morphogen', [], 'threshold', [], 'mode', 'min', 'axis', [1 0 0] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'morphogen', 'threshold', 'mode', 'axis' );
    if ~ok, return; end

    % Find the cells to look at.
    [count,whichmap] = leaf_countBioCells( m, ...
        'morphogen', s.morphogen, 'threshold', s.threshold, 'mode', s.mode );
    
    % Calculate their centroids.
    centroids = biocellCentroids( m, whichmap );
    
    % Their areas are already stored in the mesh.
    areas = m.secondlayer.cellarea(whichmap);
    
    % Project the centroids onto the axis.
    theaxis = s.axis/norm(s.axis);
    projections = sum(centroids.*repmat(theaxis,count,1),2);
end
