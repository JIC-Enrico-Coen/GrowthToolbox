function selectCellMgenMenu_Callback()
    [clickedItem,tag,fig,handles] = getGFtboxFigFromGuiObject();
    if isempty(fig) || ~ishghandle(fig)
        return;
    end
end
