function P = mul3n( M, N )
%P = mul3n( M, N )
%   M and N are 3*3*n matrices.
%   P is set to a matrix the same size, such that P(:,:,i) =
%   M(:,:,i)*N(:,:,i).  This is more efficient than iterating through the
%   slices when n is at least 20.

    P = zeros(size(M));
    for i=1:3
        for j=1:3
           P(i,j,:) = M(i,1,:) .* N(1,j,:) + ...
                      M(i,2,:) .* N(2,j,:) + ...
                      M(i,3,:) .* N(3,j,:);
        end
    end
end
           