function m = leaf_mgen_reset( m, varargin )
%m = leaf_mgen_reset( m )
%   Set the values of all morphogens, and their production rates and clamp
%   settings, to zero everywhere.
%
%   Example:
%       m = leaf_mgen_reset( m );
%
%   Equivalent GUI operation: clicking the "Set zero all" button in the
%   "Morphogens" panel.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    if ~isempty(varargin)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(args) );
    end
    
    m = zerogrowth( m, 'all' );
end
