function items = layoutItem( items )
    numChildren = length(items.children);
    if numChildren==0
        return;
    end
    positions = zeros( numChildren, 4 );
    for i=1:numChildren
        items.children{i} = layoutItem( items.children{i} );
        positions(i,:) = items.children{i}.position;
    end
    if items.horizontal
        xpositions = [ items.edge(1); items.edge(1) + cumsum( positions(:,3) + items.separation ) ];
        maxheight = max(positions(:,4));
        items.position = [ 0, 0, ....
                           xpositions(end)-items.separation+items.edge(3), ...
                           items.edge(2) + items.edge(4) + maxheight ];
        positions(:,1) = xpositions(1:(end-1));
        positions(:,2) = items.edge(2);
        outerpositions = positions;
        outerpositions(:,4) = maxheight;
    else
        ypositions = [ items.edge(2); items.edge(2) + cumsum( positions(:,4) + items.separation ) ];
        maxwidth = max(positions(:,3));
        items.position = [ 0, 0, ...
                           items.edge(1) + items.edge(3) + maxwidth, ...
                           ypositions(end)-items.separation+items.edge(4) ];
        positions(:,1) = items.edge(1);
        positions(:,2) = ypositions(1:(end-1));
        outerpositions = positions;
        outerpositions(:,3) = maxwidth;
    end
    for i=1:numChildren
        items.children{i}.outerposition = outerpositions(i,:);
        items.children{i}.position = setRectWithinRect( ...
            items.children{i}.position, outerpositions(i,:), items.children{i}.sticky );
    end
    items.outerposition = items.position;
end

function result = setIntervalWithinInterval( inner, outer, sticky1, sticky2 )
    inner(2) = min(inner(2),outer(2));
    if sticky1
        if sticky2
            result = outer;
        else
            result = [ outer(1), inner(2) ];
        end
    else
        if sticky2
            result = [ outer(1) + outer(2) - inner(2), inner(2) ];
        else
            result = [ outer(1) + (outer(2) - inner(2))/2, inner(2) ];
        end
    end
end

function rect = setRectWithinRect( rect, outerrect, sticky )
    hpos = setIntervalWithinInterval( ...
                        rect([1,3]), outerrect([1,3]), ...
                        sticky(1), sticky(3) );
    vpos = setIntervalWithinInterval(  ...
                        rect([2,4]), outerrect([2,4]), ...
                        sticky(2), sticky(4) );
    rect = [ hpos(1), vpos(1), hpos(2), vpos(2) ];
end
