function vvlayer = plotVVLayerOptions( vvlayer, varargin )
%vvlayer = plotVVLayerOptions( vvlayer, ... )
%   Set plotting options for vvlayer.
%
%   Options:
%
%   In all of the following options, the uppercase suffixes C, W, and M
%   refer to vertexes belonging to cell interiors, cell wall, and cell
%   membranes.  In pairs, they refer to edges joining vertexes of the given
%   two kinds.
%
%   vertexcolorC, ...M, ...W: the colours of vertexes (when they are not
%       being colored according to a morphogen value).
%
%   edgecolorCM, ...MM, ...MW, ...WW: the colors of edges.
%
%
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    if ~isfield( vvlayer, 'plotoptions' )
        vvlayer.plotoptions = defaultVVplotoptions();
    else
        vvlayer.plotoptions = defaultFromStruct( vvlayer.plotoptions, defaultVVplotoptions() );
    end
    vvlayer.plotoptions = defaultFromStruct( s, vvlayer.plotoptions );
end
