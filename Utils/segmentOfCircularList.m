function [indexes,values] = segmentOfCircularList( cl, v1, v2 )
%[indexes,values] = segmentOfCircularList( cl, v1, v2 )
%   cl is a circular array in which both v1 and v2 occur once.  Find
%   the segment of cl strictly between v1 and v2.
%   If v1 is empty and v2 is present, the list from the start up to bevore
%   v2 is returned.  If v1 is present and v2 is empty, the list from after
%   v1 to the end is returned.  If both are empty, the whole list is
%   returned.

    ne = length(cl);
    if isempty(v1)
        if isempty(v2)
            indexes = 1:ne;
        else
            indexes = 1:(find(cl==v2)-1);
        end
    elseif isempty(v2)
        indexes = (find(cl==v1)+1):ne;
    else
        first = find(cl==v1);
        last = find(cl==v2);
        if first==ne
            indexes = 1:(last-1);
        elseif last==1
            indexes = (first+1):ne;
        elseif first < last
            indexes = (first+1):(last-1);
        else
            indexes = [ (first+1):ne, 1:(last-1) ];
        end
    end
    if nargout > 1
        values = cl(indexes);
    end
end

