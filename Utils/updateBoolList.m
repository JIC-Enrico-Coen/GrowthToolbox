function [bools,turnedon,turnedoff] = updateBoolList( bools, newbools, mode )
    switch mode
        case 'replace'
            turnedon = setdiff( newbools, bools );
            turnedoff = setdiff( bools, newbools );
            bools = newbools;
        case 'add'
            turnedon = setdiff( newbools, bools );
            turnedoff = [];
            bools = union( bools, newbools );
        case 'rem'
            turnedon = [];
            turnedoff = setdiff( bools, newbools );
            bools = setdiff( bools, newbools );
        case 'tog'
            turnedon = setdiff( newbools, bools );
            turnedoff = intersect( newbools, bools );
            bools = setxor( bools, newbools );
    end
end

function [b,waslist] = forceBitmap( b, sz )
    waslist = ~islogical(b);
    if waslist
        definitelybools = false( sz );
        definitelybools(b) = true;
        b = definitelybools;
    end
end
