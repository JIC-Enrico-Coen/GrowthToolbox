function ab = combineAxisBounds( ab1, ab2 )
    if length(ab1) < length(ab2)
        ab1(length(ab2)) = 0;
    elseif length(ab1) > length(ab2)
        ab2(length(ab1)) = 0;
    end
    ab = zeros(size(ab1));
    ab(1:2:end) = min( ab1(1:2:end), ab2(1:2:end) );
    ab(2:2:end) = max( ab1(2:2:end), ab2(2:2:end) );
end