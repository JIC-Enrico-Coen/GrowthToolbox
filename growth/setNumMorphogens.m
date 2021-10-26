function mesh = setNumMorphogens( mesh, n )
%mesh = setNumMorphogens( mesh, n )
%   Set the number of morphogens of the mesh, either discarding excess
%   morphogens or creating new ones.

    global gPerMgenDefaults

    curNum = size( mesh.morphogens, 2 );
    mesh.morphogens = procrustesWidth( mesh.morphogens, n );
    mesh.morphogenclamp = procrustesWidth( mesh.morphogenclamp, n );
    if n < length(mesh.conductivity)
        mesh.conductivity = mesh.conductivity(1:n);
    else
        mesh.conductivity((end+1):n) = gPerMgenDefaults.conductivity;
    end
    if n < curNum
        if mesh.globalProps.activeGrowth > n
            mesh.globalProps.activeGrowth = n;
        end
        if mesh.globalProps.displayedGrowth > n
            mesh.globalProps.displayedGrowth = n;
        end
    end
%    fprintf( 1, 'setNumMorphogens( %d ), size now %d %d\n', ...
%        n, size(mesh.morphogens) );
end
