function m = leaf_setBioEdgeIndexedProperties( m, varargin )
%m = leaf_setBioEdgeIndexedProperties( m, ... )
%   Every cell wall segment has an index number which selects a certain set
%   of properties (at present, properties determining how it will be
%   drawn).  This procedure sets these properties for edges having a given
%   index.  It is not necessary that there be any edges having this index,
%   but whatever edges do have this inde will be drawn according to these
%   properties.
%
%   Options:
%       'index'     The index for which properties are to be set.
%       'LineWidth' The thickness in pixels with which edges are to be
%                   drawn.  Widths can be fractional
%       'Color'     The colour (an RGB value) of the edge.
%
%   If LineWidth or Color is omitted, the current value is unchanged; if
%   this is the first time properties have been set for this index, they
%   default to the values for index 1.
%
%   Note that thin lines (width less than 2) generally do not show up well
%   in colours other than black (on a light background) or white (on a dark
%   background.  Small distinctions of colour for thin lines are invisible.
%
%   These indexed properties are static properties of the whole project.
%   The indexes of edges, and the index that will be given to every new
%   edge, are dynamic properties, i.e. potentially different in every saved
%   stage within a project.
%
%   See also: leaf_setNewBioEdgeIndex

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    ok = checkcommandargs( mfilename(), s, 'incl', ...
        'index' );
    if ~ok, return; end
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'index', 'LineWidth', 'Color' );
    if ~ok, return; end
    
    if s.index < 1
        fprintf( 1, '%s: ''index'' option must be a positive integer\n', ...
            mfilename(), s.index );
        return;
    end
    
    index = s.index;
    s = rmfield( s, 'index' );
    
    if index <= length(m.secondlayer.indexededgeproperties)
        props = m.secondlayer.indexededgeproperties(index);
    else
        props = m.secondlayer.indexededgeproperties(1);
    end
    props = setFromStruct( props, s );
    m.secondlayer.indexededgeproperties(index) = props;
end
