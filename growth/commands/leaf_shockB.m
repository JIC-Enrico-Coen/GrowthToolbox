function m = leaf_shockB( m, varargin )
%m = leaf_shockB( m, amount )
%   AMOUNT is between 0 and 1.  Mark that proportion of randomly selected
%       cells of the B layer with random colours.  At least one cell will
%       always be marked.  If there is no B layer, the command is ignored.
%   Example:
%       m = leaf_shockB( m, 0.3 );
%
%   Equivalent GUI operation: "Shock cells" button on the Bio-B panel.
%   The accompanying slider and text box set the proportion of cells to shock.
%
%   Topics: OBSOLETE, Bio layer 2.

    if isempty(m), return; end
    [ok, amount, args] = getTypedArg( mfilename(), 'double', varargin );
    if ~ok, return; end
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(args) );
    end

    m = shockBioB( m, amount );
end
