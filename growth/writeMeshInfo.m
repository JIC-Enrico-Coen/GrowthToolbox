function writeMeshInfo( fid, m )
    % Write out the morphogen properties: diffusion, decay, and mutation.
    fprintf( fid, '\n' );
    full3d = usesNewFEs( m );
    if full3d
        fprintf( fid, '%% Mesh type: volumetric\n' );
    elseif isfield( m.meshparams, 'type' )
        fprintf( fid, '%% Mesh type: %s\n', m.meshparams.type );
    else
        fprintf( fid, '%% Mesh type: general\n' );
    end
    f = sort( fieldnames( m.meshparams ) );
    for i=1:length(f)
        if ~strcmp( f{i}, 'type' )
            x = m.meshparams.(f{i});
            fprintf( fid, '%% %15s: %s\n', f{i}, num2string( x ) );
        end
    end
    
    fprintf( fid, '\n' );
    nummgens = size( m.morphogens, 2 );
    [cpar,cper] = averageConductivity( m );
    if true || any( [cpar,cper] ) || any( m.mgen_absorption(:) ~= 0 ) || any( m.mutantLevel ~= 1 )
        fprintf( fid, '%% %20s    Diffusion   Decay   Dilution   Mutant\n', 'Morphogen' ); 
        fprintf( fid,   '%% %20s-----------------------------------------\n', '---------' );
        for i=1:nummgens
            c = [ cpar(i) cper(i) ];
            a = mean(m.mgen_absorption(:,i));
            d = m.mgen_dilution(i);
            mu = m.mutantLevel(i);
            if true || c || a || (mu ~= 1)
                fprintf( fid, '%% %20s  ', m.mgenIndexToName{i} );
                if all(c == 0)
                    fprintf( fid, '    %7s', '----' );
                elseif c(1)==c(2)
                    fprintf( fid, '    %7.3g', c(1) );
                else
                    fprintf( fid, '%5.3g %5.3g', c );
                end
                if a
                    fprintf( fid, ' %7.3g', a );
                else
                    fprintf( fid, ' %7s', '----' );
                end
                if d
                    fprintf( fid, ' %10s', 'yes' );
                else
                    fprintf( fid, ' %10s', '----' );
                end
                if mu ~= 1
                    fprintf( fid, '  %7.3g', mu );
                else
                    fprintf( fid, '  %7s', '----' );
                end
                fprintf( fid, '\n' );
            end
        end
        fprintf( fid, '\n' );
    end
    
    return;

    % Poission's ratio
    fprintf( fid, '%% Poisson''s ratio: %g.\n', m.globalProps.poissonsRatio );

    fprintf( fid, '%% Thickness params: rel %g, abs %g, areal %g, physical %s\n', ...
        m.globalProps.thicknessRelative, ...
        m.globalDynamicProps.thicknessAbsolute, ...
        m.globalProps.thicknessArea, ...
        m.globalProps.thicknessMode );
    
    fprintf( fid, '%% Negative growth allowed: %c\n', ...
        boolchar( m.globalProps.allowNegativeGrowth ) );
    
    fprintf( fid, '%% Minimum polarisation gradient %g.\n', ...
        m.globalProps.mingradient );
    
    fprintf( fid, '%% Time step %g %ss.\n', ...
        m.globalProps.timestep, ...
        m.globalProps.timeunitname );
    
    if m.globalDynamicProps.locatenode > 0
        fprintf( fid, '%% Node %d is fixed at [%g, %g, %g].\n', ...
            m.globalDynamicProps.locatenode, ...
            m.nodes(m.globalDynamicProps.locatenode,:) );
    end
    
    if m.globalProps.maxFEcells==0
        fprintf( fid, '%% Number of FEs is unlimited.\n' );
    else
        fprintf( fid, '%% Maximum number of FEs is %d.\n', ...
            m.globalProps.maxFEcells );
    end
    
    fprintf( fid, '%% Long edges may%s be split.\n', ...
        boolchar( m.globalProps.allowSplitLongFEM, '', ' not' ) );
    
    fprintf( fid, '%% Edges may%s be split near a bend.\n', ...
        boolchar( m.globalProps.allowSplitBentFEM, '', ' not' ) );
    
    if m.globalProps.allowSplitBio
        if m.globalProps.bioAsplitcells
            fprintf( fid, '%% Biological cells may be split.\n' );
        else
            fprintf( fid, '%% Biological cell splitting is faked by splitting the edges only.\n' );
        end
    else
        fprintf( fid, '%% Biological cells may not be split.\n' );
    end
    
    if m.globalProps.maxBioAcells==0
        fprintf( fid, '%% Number of biological cells is unlimited.\n' );
    else
        fprintf( fid, '%% Maximum number of biological cells is %d.\n', ...
            m.globalProps.maxBioAcells );
    end
    
    fprintf( fid, '%% Edge flipping is%s allowed.\n', ...
        boolchar( m.globalProps.allowFlipEdges, '', ' not' ) );
    
    fprintf( fid, '%% Thin triangle elision is%s allowed.\n', ...
        boolchar( m.globalProps.allowElideEdges, '', ' not' ) );
    
    fprintf( fid, '%% The mesh is%s constrained to be flat.\n', ...
        boolchar( m.globalProps.alwaysFlat, '', ' not' ) );
    
    fprintf( fid, '%% The mesh is%s two-dimensional.\n', ...
        boolchar( m.globalProps.twoD, '', ' not' ) );
    
    fprintf( fid, '%% Growth is %s.\n', ...
        boolchar( m.globalProps.growthEnabled, 'enabled', 'disabled' ) );
    
    fprintf( fid, '%% Diffusion is %s.\n', ...
        boolchar( m.globalProps.diffusionEnabled, 'enabled', 'disabled' ) );
    
    fprintf( fid, '%% Deformation is %s.\n', ...
        boolchar( m.globalProps.plasticGrowth, 'plastic', 'elastic' ) );
    
    fprintf( fid, '%% The growth equations are solved by the %s method.\n', ...
        m.globalProps.solver );
    
    fprintf( fid, '%% Solver tolerance for elasticity %g.\n', ...
        m.globalProps.solvertolerance );
    
    fprintf( fid, '%% Solver tolerance for diffusion %g.\n', ...
        m.globalProps.diffusiontolerance );
    
    fprintf( fid, '\n' );
end
