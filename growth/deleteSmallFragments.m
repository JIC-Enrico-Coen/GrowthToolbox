function [m,delinfo] = deleteSmallFragments( m, deleteNum )
%[m,delinfo] = deleteSmallFragments( m, deleteNum )
%   Delete every connected component of m containing fewer than
%   deleteNum elements. If this would delete the whole of m, then the
%   a component of m containing the largest number of elements is retained.

    delinfo = [];
    if deleteNum <= 0
        return;
    end

    m = setComponentInfo( m );
    numcpts = length( m.componentinfo.nodesets );
    
    deleteCpts = false( 1, numcpts );
    biggestComponent = 0;
    biggestSize = 0;
    for i=1:numcpts
        if numel( m.componentinfo.cellsets{i} ) <= deleteNum
            deleteCpts( i ) = true;
            if numel( m.componentinfo.cellsets{i} ) > biggestSize
                biggestComponent = i;
            end
        end
    end
    
    if all(deleteCpts)
        % An empty mesh is not allowed. Therefore we retain the component
        % with the largest number of elements.
        deleteCpts(biggestComponent) = false;
    end
    
    if any( deleteCpts )
        elementsToDelete = false( size( m.tricellvxs, 1 ) );
        for i=find(deleteCpts)
            elementsToDelete(m.componentinfo.cellsets{i}) = true;
        end
        [m,delinfo] = deleteFEs(m,find(elementsToDelete));
    end
    
    m = rmfield( m, 'componentinfo' );
end