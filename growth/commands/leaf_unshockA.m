function m = leaf_unshockA( m, varargin )
%m = leaf_unshockA( m )
%   Restore all cells of the Bio-A layer to their unshocked state.
%   Example:
%       m = leaf_unshockA( m );
%
%   Equivalent GUI operation: "Unshock all cells" button on the Bio-A panel.
%
%   Topics: Bio layer.

    if isempty(m), return; end
    if ~isempty(varargin)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(varargin) );
    end

    shockedCells = m.secondlayer.cloneindex > 0;
    m.secondlayer.cloneindex(shockedCells) = 0;
    if ~isempty( m.secondlayer.cellcolor )
        m.secondlayer.cellcolor(shockedCells,:) = ...
            secondlayercolor( length(find(shockedCells)), ...
                m.globalProps.colorparams(1,:) );
    end
end
