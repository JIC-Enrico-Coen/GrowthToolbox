function k = rotateK( k, R )
%k = rotateK( k, R )
%   Rotate the K matrix by a rotation R in column vector form.

    for i=3:3:size(k,2)
        range = [i-2,i-1,i];
        k(:,range) = k(:,range) * R';
    end
    for i=3:3:size(k,1)
        range = [i-2,i-1,i];
        k(range,:) = R * k(range,:);
    end
end
