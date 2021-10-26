function mgenColorPick( hObject, title, positive )
    c = bgColorPick( hObject, title );
    if length(c)==3
        handles = guidata( hObject );
        if ~isempty(handles.mesh)
            cmapMenuLabel = getMenuSelectedLabel( handles.colorScalePopupMenu );
            issplit = strcmp( cmapMenuLabel, 'Split Mono' );
            ismonochrome = issplit || strcmp( cmapMenuLabel, 'Monochrome' );
            ismultimgen = get( handles.drawmulticolor, 'Value' );
            mgenIndex = handles.mesh.globalProps.displayedGrowth;
            if mgenIndex ~= 0
                if positive
                    handles.mesh.mgenposcolors( :, mgenIndex ) = c';
                else
                    handles.mesh.mgennegcolors( :, mgenIndex ) = c';
                end
                guidata( hObject, handles );
            end
            if ismonochrome ...
                    || (ismultimgen && true) % Should test if current mgen is in current multiset
                notifyPlotChange( handles );
            end
        end
    end
end
