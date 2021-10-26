function plotCellFactorsFromGUI( h )
    if ~isempty( h.mesh )
        fig = h.GFTwindow;
        plotargs = { 'cellbodyvalue', h.mesh.plotdefaults.cellbodyvalue };
        notifyPlotChange( h, plotargs{:} );
        h = guidata( fig );
        setMyLegend( h.mesh );
    end

