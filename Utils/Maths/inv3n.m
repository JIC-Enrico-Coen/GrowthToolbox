function N = inv3n( M )
%M is a 3*3*N matrix.  Each of its 3*3 slices is inverted.

    next3 = [2 3 1];

    N = zeros(size(M));
    for i=1:3
        i1 = next3(i);
        i2 = next3(i1);
        for j=1:3
            j1 = next3(j);
            j2 = next3(j1);
            N(j,i,:) = M(i1,j1,:).*M(i2,j2,:) - M(i1,j2,:).*M(i2,j1,:);
        end
    end
    det = M(1,1,:) .* N(1,1,:) + M(1,2,:) .* N(2,1,:) + M(1,3,:) .* N(3,1,:);
    for i=1:3
        for j=1:3
            N(i,j,:) = N(i,j,:) ./ det;
        end
    end
  % for i=1:size(M,3)
  %     check = N(:,:,i) * M(:,:,i) - eye(3)
  % end
end