function pcv = VVperCellValues( m )
%pcv = VVperCellValues( vvlayer )
%   Returns, for each morphogen, and each cell, the total amount of that
%   morphogen in the cytoplasm, the membrane, and in total.
%   The result is a C*N*3 array, where there are C cells, N morphogens, and
%   the 3 rows are the cytoplasm, membrane, and total values.

    nummgens = size(m.secondlayer.vvlayer.mgenM,2);
    pcv = zeros(length(m.secondlayer.cellarea),nummgens,3);
    for i=1:nummgens
        pcv(:,i,1) = VVconvertMembraneToCell( m, m.secondlayer.vvlayer.mgenM(:,i) ) .* m.secondlayer.cellarea;
        pcv(:,i,2) = m.secondlayer.vvlayer.mgenC(:,i) .* m.secondlayer.cellarea;
    end
    pcv(:,:,3) = pcv(:,:,1) + pcv(:,:,2);
end
