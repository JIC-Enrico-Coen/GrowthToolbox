function [mgenindex,mgenname] = getDisplayedMgen( handles )
    if isempty( handles.mesh )
        mgenindex = 0;
        mgenname = '';
    else
        mgenname = mgenNameFromMgenMenu( handles );
        if isfield( handles.mesh.mgenNameToIndex, mgenname )
            mgenindex = handles.mesh.mgenNameToIndex.(mgenname);
        else
            mgenindex = 0;
        end
    end
end
