function [ newToOld, oldToNew ] = makeRenumbering( boolmap )
%[ newToOld, oldToNew ] = makeRenumbering( boolmap )
%   boolmap is a bitmap indicataing which elements of a vector are to be
%   deleted.  If W == V(boolmap), then we will have
%   W == V(newToOld) and W(oldToNew) == V except where oldToNew is zero.

    newToOld = find( boolmap );
    oldToNew = zeros( 1, length(boolmap), 'int32' );
    oldToNew(newToOld) = int32(1:length(newToOld));
end
