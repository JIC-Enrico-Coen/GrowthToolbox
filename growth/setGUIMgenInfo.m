function h = setGUIMgenInfo( h, m )
%setGUIMgenInfo( h )
%   Cause the GUI to display values relating to a given morphogen.
%   If no mgenIndex is specified, get it from the displayedGrowthMenu item.
%   If there is no mesh, restore default values.

    global gPerMgenDefaults

    if nargin < 2
        m = h.mesh;
    end
    [mgenIndex,mgenName] = getDisplayedMgen( h );
    if mgenIndex==0
        return;
    end
    perMgenValues = gPerMgenDefaults;
    if isempty( m )
        perMgenValues.conductivity = 0;
        perMgenValues.interpType = 'mid';
    else
        perMgenValues = struct( 'mgen_absorption', m.mgen_absorption(:,mgenIndex), ...
                               'mutantLevel', m.mutantLevel(mgenIndex), ...
                               'mgenswitch', 1, ...
                               'mgen_dilution', m.mgen_dilution(mgenIndex), ...
                               'mgen_transportable', false, ...
                               'mgen_plotpriority', 0, ...
                               'mgen_plotthreshold', 0, ...
                               'conductivity', averageConductivity( m, mgenIndex ), ...
                               'mgenposcolors', m.mgenposcolors(:,mgenIndex), ...
                               'mgennegcolors', m.mgennegcolors(:,mgenIndex), ...
                               'interpType', m.mgen_interpType{mgenIndex});
    end
    if isempty( m )
        set( h.legend, 'String', '', 'Visible', 'off' );
    else
        setMyLegend( m );
    end
    
    
    set( h.mgenColorChooser, 'BackgroundColor', perMgenValues.mgenposcolors' );
    set( h.mgenNegColorChooser, 'BackgroundColor', perMgenValues.mgennegcolors' );
    setDoubleInTextItem( h.absorptionText, mean(perMgenValues.mgen_absorption) );
    setSliderAndText( h.mutantslider, perMgenValues.mutantLevel );
    set( h.allowDilution, 'Value', perMgenValues.mgen_dilution );
    setDoubleInTextItem( h.conductivityText, perMgenValues.conductivity );
    interpButtons = get( h.splitMgenButtonGroup, 'Children' );
    for i=1:length(interpButtons)
        if strcmp( getGuiItemValue(interpButtons(i)), perMgenValues.interpType )
            set( interpButtons(i), 'Value', 1 );
        end
    end
    h = updateVertexInfoDisplay( h, [], mgenIndex );
    if isempty(mgenName)
        set( h.morphdistpanel, 'Title', 'Morphogens' );
    else
        set( h.morphdistpanel, 'Title', ['Morphogen: ', mgenName] );
    end
    enableMutations( h );
end
