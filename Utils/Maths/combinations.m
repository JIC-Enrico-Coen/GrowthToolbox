function c = combinations(n,i)
%c = combinations(n,i)
%   Calculate n!/i!(n-i)!

    if i<0
        c = 0;
    else
        c = 1;
        num = n;
        for k=1:i
            c = c*num/k;
            num = num-1;
        end
    end
end


