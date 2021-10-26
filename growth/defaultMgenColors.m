function colors = defaultMgenColors( indexes )
    colors = HSVtoRGB( [ (indexes(:)-1)/12, ones( numel( indexes ), 2 ) ] )';
end
