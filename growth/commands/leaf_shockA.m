function m = leaf_shockA( m, varargin )
%m = leaf_shockB( m, amount )
%   AMOUNT is between 0 and 1.  Mark that proportion of randomly selected
%       cells of the A layer with random colours.  At least one cell will
%       always be marked.  If there is no A layer, the command is ignored.
%   Example:
%       m = leaf_shockA( m, 0.3 );
%
%   Equivalent GUI operation: "Shock cells" button on the Bio-A panel.
%   The accompanying slider and text box set the proportion of cells to shock.
%
%   Topics: Bio layer.

    if isempty(m), return; end
    [ok, amount, args] = getTypedArg( mfilename(), 'double', varargin );
    if ~ok, return; end
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(args) );
    end

    shockedCells = randints( length( m.secondlayer.cloneindex ), amount );
    m.secondlayer.cloneindex( shockedCells ) = ...
        m.secondlayer.cloneindex( shockedCells ) + 1;
    if ~isempty( m.secondlayer.cellcolor )
        m.secondlayer.cellcolor(shockedCells,:) = ...
            secondlayercolor( length(shockedCells), ...
                m.globalProps.colorparams(2,:) );
    end
end
