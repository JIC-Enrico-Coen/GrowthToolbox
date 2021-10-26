function bc = normaliseBaryCoords( bc )
%bc = normaliseBaryCoords( bc )
%   Force all elements of bc to be in the range 0..1 with a sum of 1.
%   bc may be a matrix in which each row is a set of barycentric
%   coordinates.

    dims = size(bc,2);
    if false
        m = min(bc,[],2);
        m = min(m,0);
        newbc = bc - m*ones(1,size(bc,2));
      % newbc = max(bc,0);
        sumbc = sum(newbc,2);
        bc = newbc ./ (sumbc * ones(1,size(newbc,2)));
    else
        for i=1:size(bc,1)
            nonpos = bc(i,:) <= 0;
            numnonpos = numel(find(nonpos));
            if numnonpos==dims-1
                bc(i,:) = 0;
                bc(i,~nonpos) = 1;
%             elseif numnonpos==1
%                 bc1 = bc(i,:) - bc(i,nonpos);
%                 bc(i,:) = bc1/sum(bc1);
            elseif numnonpos > 0
                bc1 = bc(i,:) - min(bc);
                bc(i,:) = bc1/sum(bc1);
            end
        end
    end
end
