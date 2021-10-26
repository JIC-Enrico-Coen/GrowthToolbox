function m = leaf_splitsecondlayer( m, varargin )
%m = leaf_splitsecondlayer( m )
%   Split every cell in the second layer.  Reset the splitting threshold
%   to make the new cell sizes the target sizes.
%
%   Equivalent GUI operation: None.
%
%   Topics: Bio layer.

    if isempty(m), return; end
    if ~isempty(varargin)
        fprintf( 1, '%s: %d extra arguments ignored.\n', ...
            mfilename(), length(varargin) );
    end
    
    m = splitSecondLayerCells( m, 1 );
    m = setSplitThreshold( m );
end
