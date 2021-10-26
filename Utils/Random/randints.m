function r = randints( n, p )
%r = randints( n, p )
%   Randomly select a proportion p of the integers from 1 to n.
%   Each integer has a probability p of being chosen; the number of
%   integers selected will therefore average pn but will vary randomly from
%   that figure.  At least one integer will always be selected unless n is
%   zero.  The integers are returned in ascending order.

    if n <= 0
        r = [];
    else
        rmap = rand(1,n) <= p;
        r = find(rmap);
        if isempty(r), r = randi([1 n]); end
    end
end
