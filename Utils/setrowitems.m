function a = setrowitems( a, ri, newvals )
% a is an N*K array.  ri is an N*M array whose values are in the range 1:K,
% and each row of which contains no repeated values.  newvals is an array
% the same shape as ri.
% For every row i, set the members of that row of a designated by ri(i,:)
% to the corresponding elements of newvals.

% Slower for large matrices.
%     for i=1:size(a,1)
%         a(i,ri(i,:)) = newvals(i,:);
%     end
    
    ai = sub2ind(size(a), repmat( (1:size(a,1))', 1, size(ri,2) ), ri );
    a(ai) = newvals(:);
end
