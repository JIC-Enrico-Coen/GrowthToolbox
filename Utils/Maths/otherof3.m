function k = otherof3( i, j )
%k = otherof3( i, j )
%   If i and j are distinct digits in the range 1..3, k is the third digit.
%   i and j can be arrays of the same shape.

    % A cunning formula that is just as fast as the longer code below, and
    % is vectorised for lightning speed.  However, it is not robust against
    % invalid values of i or j.
    k = (i ~= j) .* (6-i-j);

%     if i==1
%         if j==2
%             k = 3;
%         else
%             k = 2;
%         end
%     elseif i==2
%         if j==3
%             k = 1;
%         else
%             k = 3;
%         end
%     elseif j==1
%         k = 2;
%     else
%         k = 1;
%     end
end
