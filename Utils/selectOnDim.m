function a = selectOnDim( a, dim, map )
%a = selectOnDim( a, dim, map )
%   Select on the given dimension of A the cross-sections specified by MAP.
%   If MAP is logical it is a bitmap of the selected sections, otherwise
%   it is a list of the indexes of the selected sections.

    sza = size(a);
    len = sza(dim);
    
    if ~islogical(map)
        newmap = false( 1, len );
        newmap(map) = true;
        map = newmap;
    end
    
    if all(map)
        return;
    end
    
    a = reshape( a, prod(sza(1:(dim-1))), len, prod(sza((dim+1):end)) );
    a = a(:,map,:);
    a = reshape( a, [ sza(1:(dim-1)), sum(map), sza((dim+1):end) ] );
end