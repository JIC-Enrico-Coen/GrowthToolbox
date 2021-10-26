function e = edgeProduct( e1, e2 )
    if isempty(e1)
        e = e2;
    elseif isempty(e2)
        e = e1;
    else
        n1 = max(e1(:));
        n2 = max(e2(:));
        s1 = numel(e1);
        s2 = numel(e2);
        e = zeros(0,2);

        % One copy of e1 for every vertex in e2
        for i=1:n2
            ee = e1 + (i-1)*n1;
            e = [ e; ee ];
        end

        % One copy of e2 for every vertex in e1
        e2a = (e2-1)*n1;
        for i=1:n1
            ee = e2a + i;
            e = [ e; ee ];
        end
    end
end
