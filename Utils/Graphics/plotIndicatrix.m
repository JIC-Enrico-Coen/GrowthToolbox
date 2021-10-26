function [ph,lh] = plotIndicatrix( ax, ellipsedata, axisdata, varargin )
%plotIndicatrix( ax, ellipsedata, axisdata, ... )
%   Plot the ellipse and axis data returned by plotdataIndicatrix in the
%   given axes object.
%
%   The options are:
%
%   'patchcolor'    The colour to draw each patch.  Default green.
%
%   'line color'    The colour to draw each axis and the edge of each
%                   patch.  Default black.
%
%   'FaceAlpha'     The opacity of each patch.  Default 1.
%
%   'EdgeAlpha'     The opacity of each line.  Default 1.
%
%   The return values are handles to the patch objects representing the set
%   of ellipses and the set of axis lines. Both of these are actually patch
%   handles.  We use patch() to draw the axes rather than line(), because
%   the latter does not support transparency.

    s = struct( varargin{:} );
    s = defaultfields( s, ...
        'patchcolor', 'g', ...
        'linecolor', 'k', ...
        'FaceAlpha', 1, ...
        'EdgeAlpha', 1 );
        
    oldhold = get( ax, 'NextPlot' );
    hold(ax,'on');
    if ~isempty( ellipsedata )
        ph = patch( ellipsedata(:,:,1), ellipsedata(:,:,2), ellipsedata(:,:,3), s.patchcolor, ...
            'Parent', ax, ...
            'FaceAlpha', s.FaceAlpha, ...
            'EdgeColor', s.linecolor, 'EdgeAlpha', s.EdgeAlpha );
    else
        ph = [];
    end
    if ~isempty( axisdata )
        lh = patch( axisdata(:,1), axisdata(:,2), axisdata(:,3), 'w', ...
            'Parent', ax, ...
            'FaceAlpha', 0, ...
            'LineStyle', '-', 'EdgeColor', s.linecolor, 'EdgeAlpha', s.EdgeAlpha );
    else
        lh = [];
    end
    set( ax, 'NextPlot', oldhold );
end
