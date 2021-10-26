function [values,varargout] = deleteRepeatedValues( values, zeroindexed, varargin )
    [values,~,ic] = unique( values, 'rows', 'stable' );
    ic = int32(ic);
    
    offset = int32(zeroindexed);
    
    varargout = cell( 1, length(varargin) );
    
    for i=1:length(varargin)
        varargout{i} = reshape( ic( varargin{i}+offset )-offset, size( varargin{i} ) );
    end
end
