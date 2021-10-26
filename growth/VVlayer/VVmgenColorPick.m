function VVmgenColorPick( hObject, title, positive )
    c = bgColorPick( hObject, title );
    if length(c)==3
        handles = guidata( hObject );
        if ~isempty(handles.mesh)
            cmapMenuLabel = getMenuSelectedLabel( h.colorScalePopupMenu );
            ismonochrome = strcmp( cmapMenuLabel, 'Monochrome' ) || strcmp( cmapMenuLabel, 'Split Mono' );
            % ismultimgen = get( handles.drawmulticolor, 'Value' );
            mgenIndex = handles.mesh.secondlayer.vvlayer.plotoptions.currentMgen;
            if mgenIndex ~= 0
                if positive
                    handles.mesh.secondlayer.vvlayer.mgenposcolors( :, mgenIndex ) = c';
                else
                    handles.mesh.secondlayer.vvlayer.mgennegcolors( :, mgenIndex ) = c';
                end
                guidata( hObject, handles );
            end
            if ismonochrome ...
                    % || (ismultimgen && true) % Should test if current mgen is in current multiset
                notifyPlotChange( handles );
            end
        end
    end
end
