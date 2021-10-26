function [m,ok] = leaf_semicircle( m, varargin )
%m = leaf_semicircle( m, ... )
%   Create a new semicircular mesh.  Parameters are as for leaf_circle.
%
%   Equivalent GUI operation: selecting "Semicircle" in the pulldown menu
%   in the "Mesh editor" panel and clicking the "New" button.
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_LEAF, LEAF_ONECELL,
%           LEAF_RECTANGLE.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s.semicircle = true;
    [m,ok] = leaf_circle( m, s );
end
