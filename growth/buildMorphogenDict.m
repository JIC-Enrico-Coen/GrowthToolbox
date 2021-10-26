function m = buildMorphogenDict( m )
%m = buildMorphogenDist( m )
%   Build a dictionary mapping morphogen names to indexes and vice versa.
%   Make sure the standard morphogens are included.

    setGlobals();
    global gLaminarMorphogenNames gVolumetricMorphogenNames
    if isVolumetricMesh( m )
        m.mgenIndexToName = gVolumetricMorphogenNames;
    else
        m.mgenIndexToName = gLaminarMorphogenNames;
    end
    m.mgenNameToIndex = invertDictionary( m.mgenIndexToName );
end
