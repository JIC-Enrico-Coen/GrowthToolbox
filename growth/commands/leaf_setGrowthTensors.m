function m = leaf_setGrowthTensors( m, tensors )
%m = leaf_setGrowthTensors( m, tensors )
%   Set a growth tensor for each finite element.  TENSORS should be a N*6
%   array, where N is the number of finite elements.  Each column should be
%   a representation of a 3x3 symmetric tensor as a 6-element vector in the
%   order [ xx, yy, zz, yz, zx, xy ].  TENSORS may also be a 1*6 array, in
%   which case it will be replicated to the required size.
%
%   These growth tensors will be used as the specified growth behaviour if
%   the 'useGrowthTensors' property is set to true, otherwise they are
%   ignored.  If the 'useMorphogens' property is also true, these growth
%   tensors will be added to those derived from the growth morphogens
%   (KAPAR etc.), otherwise they will be used instead of them.
%
%   To clear all the growth tensors, supply the empty array.

    if isempty(tensors)
        m.directGrowthTensors = [];
    else
        numFEs = size(m.tricellvxs,1);
        tsize = size(tensors);
        if length(tsize) ~= 2
            complain( 'Invalid tensor array supplied to %s: expected 2 dimensions, found %d.\n', ...
                mfilename(), length(tsize) );
        else
            if tsize(1)==1
                tensors = repmat( tensors, [numFEs, ones(1,length(tsize)-1)] );
                tsize = size(tensors);
            end
            if any( tsize ~= [numFEs,6] )
                complain( 'Invalid tensor array supplied to %s: expected size [%d,6], found [%d,%d].\n', ...
                    mfilename(), numFEs, size(tensors) );
            else
                m.directGrowthTensors = tensors;
            end
        end
    end
end
