function TMI = TMIndex()
    TMI = [ [1,6,5];
            [6,2,4];
            [5,4,3] ];
    return;

    TMI = zeros(3,3,3,3,2);
    s = [];
    for i=1:6
        if i <= 3
            i1 = i; i2 = i;
        else
            i1 = mod1(i+1,3);
            i2 = mod1(i+2,3);
        end
        for j=1:6
            if j <= 3
                j1 = j; j2 = j;
            else
                j1 = mod1(j+1,3);
                j2 = mod1(j+2,3);
            end
            TMI(i1,i2,j1,j2,:) = [i,j];
            TMI(i1,i2,j2,j1,:) = [i,j];
            TMI(i2,i1,j1,j2,:) = [i,j];
            TMI(i2,i1,j2,j1,:) = [i,j];
            TMI(j1,j2,i1,i2,:) = [i,j];
            TMI(j1,j2,i2,i1,:) = [i,j];
            TMI(j2,j1,i1,i2,:) = [i,j];
            TMI(j2,j1,i2,i1,:) = [i,j];
        end
    end
end

function j = mod1( ii, n )
    j = mod(ii,n);
    if j==0, j = n; end
end
