function [c1,c2,cv] = bioAColorParams( handles )
    c1 = get( handles.cellColorIndicator1, 'BackgroundColor' );
    c2 = get( handles.cellColorIndicator2, 'BackgroundColor' );
    cv = getDoubleFromDialog( handles.colorVariationText, 0 );
end
