function createDialog( fig, ddesc )
    numitems = length(ddesc)
    ddesc
    
    % Creation.
    figure( fig );
    for i=1:numitems
        item = ddesc(i);
        item.creator( item.parameters );
    end
end
