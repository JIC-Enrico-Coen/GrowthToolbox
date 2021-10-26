function m = leaf_deletesecondlayer( m, varargin )
%m = leaf_deletesecondlayer( m )
%   Delete the first biological layer.  All cells are deleted, and cell
%   history is deleted, but cell factors are not.
%
%   Equivalent GUI operation: clicking the "Delete all cells" button in the
%   "Cells" panel.
%
%   Topics: Bio layer.

    if isempty(m), return; end
    if ~isempty(varargin)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(varargin) );
    end

    m.secondlayer = deleteSecondLayerCells( m.secondlayer, true(1,length(m.secondlayer.cells)) );
end
