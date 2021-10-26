function mesh = notifySplits( mesh, splits )
    for i=1:size(splits,1)
        mesh = notifySplit( mesh, splits(i,:) );
    end
end
