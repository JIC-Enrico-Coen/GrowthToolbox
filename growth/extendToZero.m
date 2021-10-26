function range = extendToZero( range )
    if ~isempty(range)
        if length(range)==1
            if range <= 0
                range = [range 0];
            else
                range = [0 range];
            end
        else
            range(1) = min( range(1), 0 );
            range(2) = max( range(2), 0 );
            if length(range) >= 3
                range(3) = 0;
            end
        end
    end
end
