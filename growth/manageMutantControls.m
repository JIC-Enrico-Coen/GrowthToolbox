function manageMutantControls( h )
    enableMutantButtons = true; % ~get( h.allWildcheckbox, 'Value' );
    enableGUIitem( h.mutantslider, enableMutantButtons );
    enableGUIitem( h.mutanttext, enableMutantButtons );
    enableGUIitem( h.revertMutantButton, enableMutantButtons );
end
