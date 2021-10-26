function [indexed, varargout] = deleteUnusedIndexes( indexed, zeroindexed, varargin )
    offset = int32(zeroindexed);
    indexing = varargin;
    wassingle = ~iscell(indexing);
    if wassingle
        indexing = { indexing };
    end
    uindexing = cell( numel(indexing), 1 );
    for i=1:length(indexing)
        uindexing{i} = int32( indexing{i}(:) );
    end
    uindexing = cell2mat( reshape( uindexing, [], 1 ) );

    usedvalues = unique( uindexing(:) ) + offset;
    usedvalues( find( usedvalues==0, 1 ) ) = [];
    usedvaluemap = false( size(indexing,1), 1 );
    usedvaluemap( usedvalues ) = true;
    remapvalues = zeros( size(indexed,1), 1, 'int32' );
    remapvalues( usedvalues ) = int32( (1:length(usedvalues))' );
    varargout = cell(1,length(indexed));
    for i=1:length(indexing)
        varargout{i} = reshape( remapvalues( indexing{i}+offset ), size(indexing{i}) ) - offset;
    end
    indexed = indexed( usedvaluemap,: );
end
