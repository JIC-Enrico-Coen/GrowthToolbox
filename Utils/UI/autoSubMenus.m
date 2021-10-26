function autoSubMenus( parentmenu, menuinfo )
    MAX_ITEMS_PER_MENU = 30;
    numitems = length(menuinfo);
    x = MAX_ITEMS_PER_MENU;
    numlevels = 1;
    while x < numitems
        x = x*MAX_ITEMS_PER_MENU;
        numlevels = numlevels+1;
    end
    
    
    
    
    if numitems <= MAX_ITEMS_PER_MENU
        for i=1:numitems
            uimenu( parentMenu, menuinfo(i) );
        end
    else
        
    end
    
    
    
    
    
    numsubmenus = floor(numitems,MAX_ITEMS_PER_MENU);
    itemspersubmenu = 
    for i=1:numsubmenus
        m = uimenu(parentmenu, options);
        lastitem = i*MAX_ITEMS_PER_MENU;
        autoSubMenus( m, menuinfo([lastitem-MAX_ITEMS_PER_MENU+1,lastitem]) );
    end
    for i = (numsubmenus*MAX_ITEMS_PER_MENU+1):numitems
        uimenu( parentMenu, menuinfo(i) );
    end
end
