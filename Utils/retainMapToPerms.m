function [oldToNew,newToOld] = retainMapToPerms( km )
%[oldToNew,newToOld] = retainMapToPerms( km )
%   Suppose that there is a vector A (not supplied to this procedure) and
%   KM is a boolean map specifying which elements of A to retain, yielding
%   a vector B = A(KM).
%
%   The results of this procedure are mappings between indexes of A and
%   indexes of B, such that B = A(newToOld) = B(oldToNew(oldToNew>0)).

    newToOld = find(km);
    oldToNew = zeros(size(km));
    oldToNew(km) = (1:sum(km))';
end
