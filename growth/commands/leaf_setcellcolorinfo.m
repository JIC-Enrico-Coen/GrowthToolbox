function m = leaf_setcellcolorinfo( m, varargin )
% m = leaf_setcellcolorinfo( m, ... )
%   Set the information used to plot a given cell factor.
%
%   Arguments:
%   factor: The name or index of a cell factor.  Multiple factors can be
%           specified, as a cell array of names or an array of indexes, in
%           which case the same colour info will be applied to all of them.
%           If this option is empty or omitted, the color info will be used
%           when any per-cell quantity other than a cell factor is plotted
%           (e.g. cell area, or any user-defined per-cell value that is not
%           stored as a cell factor).
%   mode:   The method of mapping values to colours.  Possibilities are:
%           'posneg': the 'pos' and 'neg' arguments specify respectively
%               the colours for positive and negative values.
%           'rainbow': a standard rainbow color scale will be used.
%           'custom': an array of colours is given by the 'colors'
%               argument.  The minimum value of the factor will be mapped
%               to the first colour, and the maximum value to the last,
%               with intermediate values being mapped to interpolated
%               colors.
%           'indexed': an array of colours is given by the 'colors'
%               argument.  The factor value will be rounded to an integer
%               value n, and colour n+1 will be used.  Values out of range
%               of the colour array will be truncated to the ends.  Thus a
%               value of 0 or less is mapped to the first colour, 1 is
%               mapped to the second, etc.
%   pos:    For 'posneg' mode, the colour used for positive values.
%   neg:    For 'posneg' mode, the colour used for negative values.
%   colors: For 'custom' and 'indexed' mode, an N*3 array of N colours.
%   range: A pair of numbers, which are the values to be mapped to the ends
%           of the color scale.  Used only when autorange is false.
%   autorange: Whether to fit the color scale to the actual range of
%           values, or to the range given in the 'range' property.
%
%   To use any of Matlab's built-in color maps, set 'mode' to 'custom', and
%   set 'colors' to the color map returned by them.  For example:
%
%             m = leaf_setcellcolorinfo( m, ...
%                     ...
%                     'mode', 'custom', ...
%                     'colors', jet(100), ...
%                     ...
%                 );
%
%   The built-in color maps are parula, hsv, hot, pink, flag,
%   white, bone, colorcube, cool, copper, flag, gray, hot, hsv,
%   jet, lines, pink, prism, spring, summer, autumn, winter.
%   Each of them takes a parameter specifying how many steps you want in
%   the map.


    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    global gSecondLayerColorInfo
    setGlobals()
    s = defaultfields( s, 'factor', [] );
    colorinfofields = fieldnames( gSecondLayerColorInfo );
    [ok,s] = checkcommandargs( mfilename(), s, 'only', ...
        'factor', colorinfofields{:} );
    if ~ok, return; end
    
    if isempty(s.factor)
        % We are setting the default color info, not the color info for a
        % cell factor
        factorindexes = [];
    else
        factorindexes = name2Index( m.secondlayer.valuedict, s.factor );
        factorindexes(factorindexes==0) = [];
        if isempty(factorindexes)
            % Factors were specified, but none of them were valid.  Take no
            % action.
            return;
        end
    end
    
    if isempty( factorindexes )
        m.secondlayer.customcellcolorinfo = setFromStruct( m.secondlayer.customcellcolorinfo, s, 'existing' );
    else
        s = rmfield( s, 'factor' );
        for i=1:length(factorindexes)
            m.secondlayer.cellcolorinfo(factorindexes(i)) = setFromStruct( m.secondlayer.cellcolorinfo(factorindexes(i)), s, 'existing' );
        end
    end
end
