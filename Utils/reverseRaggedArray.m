function arr = reverseRaggedArray( arr, nullvalue )
%arr = reverseRaggedArray( arr, nullvalue )
%   ARR is an N*K array in which NULLVALUE occurs only as trailing elements
%   in each row. (A row need not contain any occurrence of NULLVALUE.) This
%   procedure reverses the non-NULLVALUE part of each row. Thus the array
%
%       [ 1 2 0 0;
%         6 1 5 5;
%         8 4 12 0 ]
%
%   is transformed to
%
%       [ 2 1 0 0;
%         5 5 1 6;
%         12 4 8 0 ]
%
%   NULLVALUE defaults to 0.

    if nargin < 2
        nullvalue = 0;
    end

%     counts = sum( arr ~= nullvalue, 2 );
%     for i=1:size(arr,1)
%         z = counts(i);
%         arr(i,1:z) = arr(i,z:-1:1);
%     end
    
    % This version is about 1.3 to 1.7 times slower than the version above.
    for i=1:size(arr,1)
        z = find(arr(i,:)==nullvalue,1);
        if isempty(z)
            arr(i,:) = arr(i,end:-1:1);
        else
            arr(i,1:(z-1)) = arr(i,(z-1):-1:1);
        end
    end
end

