function vs = normvecs( vs )
%vs = normvecs( vs )
%   Transform every non-zero row of vs into a unit vector.

    sqlengths = sum( vs.*vs, 2 );
    for i=1:size(vs,1)
        if sqlengths(i) ~= 0
            vs(i,:) = vs(i,:)/sqrt(sqlengths(i));
        end
    end
end

        
