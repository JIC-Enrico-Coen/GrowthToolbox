function i = getDisplayedMgenIndex( handles )
    if isempty( handles.mesh )
        i = 0;
    else
        mgenName = mgenNameFromMgenMenu( handles );
        if isfield( handles.mesh.mgenNameToIndex, mgenName )
            i = handles.mesh.mgenNameToIndex.(mgenName);
        else
            i = 0;
        end
    end
end
