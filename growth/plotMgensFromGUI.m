function plotMgensFromGUI( h )
    if ~isempty( h.mesh )
        mgens = [];
        if get( h.inputSelectButton, 'Value' )
            if get( h.drawmulticolor, 'Value' )
                mgens = h.mesh.plotdefaults.defaultmultiplottissue;
            else
                mgens = mgenNameFromMgenMenu( h );
            end
        end
        cellbodyvalue = '';
        if get( h.cellMgenSelectButton, 'Value' )
            cellbodyvalue = getMenuSelectedLabel(h.displayedCellMgenMenu);
        end
        fig = h.GFTwindow;
        
        if isempty( mgens )
            plotargs = { 'blank', true };
        else
            plotargs = { 'morphogen', mgens };
        end
        plotargs{end+1} = 'cellbodyvalue';
        plotargs{end+1} = cellbodyvalue;
        
        notifyPlotChange( h, plotargs{:} );
        h = guidata( fig );
        setMyLegend( h.mesh );
    end
end