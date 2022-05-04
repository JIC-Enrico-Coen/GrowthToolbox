function m = diffusegrowth( m )
% m = diffusegrowth( m )
%   Despite the name, this procedure calculates diffusion, production,
%   absorption, and transport for one simulation step.

    if getNumberOfFEs(m)==0
        return;
    end

    full3d = usesNewFEs( m );
        
%     minM = min(m.morphogens,[],1);
%     maxM = max(m.morphogens,[],1);
    
    nummgens = getNumberOfMorphogens( m );
    diffusibleMgens = false( 1, nummgens );
    transportableMgens = false( 1, nummgens );
    producibleMgens = false( 1, nummgens );
    absorbableMgens = false( 1, nummgens );
    for i=1:nummgens
        % A morphogen is diffusible if:
        %   it has a non-zero diffusion coefficient,
        %   and not all vertexes are clamped,
        %   and either its values or its production rate are non-uniform.
        diffusibleMgens(i) = ...
                     ( any( m.conductivity(i).Dpar ~= 0 ) ...
                       || any( m.conductivity(i).Dper ~= 0 ) ) ...
                     && any( m.morphogenclamp(:,i) < 1 ) ...
                     && ( any(m.morphogens(:,i) ~= m.morphogens(1,i)) ...
                          || any(m.mgen_production(:,i) ~= m.mgen_production(1,i)) );
        transportableMgens(i) = m.mgen_transportable(i) && ~isempty( m.transportfield{i} );
        producibleMgens(i) = any(m.mgen_production(:,i) ~= 0);
        absorbableMgens(i) = any(m.mgen_absorption(:,i) ~= 0);
    end
    
    if ~any( diffusibleMgens | transportableMgens | producibleMgens | absorbableMgens )
        timedFprintf( 1, 'No diffusion, production, absorption, or transport.\n' );
        return;
    end
    
    timedFprintf( 1, 'diffusegrowth: lengthscale %.3f, lengthscale^2 %.3f\n', ...
        m.globalProps.lengthscale, m.globalProps.lengthscale^2 );

    for i=1:nummgens
        if teststopbutton( m )
            return;
        end
        fixedmap = m.morphogenclamp(:,i) >= 1;
        if all(fixedmap)
            % Morphogen is fixed everywhere.  No computation required.
            continue;
        end
        
        diffusible = diffusibleMgens(i);
        transportable = transportableMgens(i);
        
        fixedvxs = find( fixedmap );
        if diffusible || transportable
            % Get the per-FE diffusion constants for morphogen i.
            numFEs = getNumberOfFEs(m);
            Dpar = m.conductivity(i).Dpar;
            Dper = m.conductivity(i).Dper;
            if ~isempty(Dpar) && all(Dpar==Dpar(1))
                Dpar = Dpar(1);
            end
            if ~isempty(Dper) && all(Dper==Dper(1))
                Dper = Dper(1);
            end
            if isempty(Dper)
                % Isotropic everywhere, possibly varying.
                conductivity = Dpar;
            else
                if length(Dpar) ~= length(Dper)
                    if length(Dpar)==1
                        Dpar = Dpar+zeros(size(Dper));
                    else
                        Dper = Dper+zeros(size(Dpar));
                    end
                end
                if all(Dper==Dpar)
                    % Isotropic everywhere, possibly varying.
                    conductivity = Dpar;
                else
                    % Anisotropic.  Calculate the conductivity tensor for
                    % each FE in the global frame.
                    conductivity = zeros( 3, 3, numFEs );
                    for ci=1:numFEs
                        conductivity(:,:,ci) = m.cellFrames(:,:,ci) ...
                                              * diag([Dpar(ci),Dper(ci),0]) ...
                                              * m.cellFrames(:,:,ci)';
                    end
                end
            end
            isotropic = size(conductivity,2)==1;
            uniform = numel(conductivity)==1;
            
            s_iso = boolchar( isotropic, 'isotropic', 'anisotropic' );
            s_unif = boolchar( uniform, 'uniform', 'nonuniform' );
            if diffusible
                if transportable
                    s = 'Diffusing/transporting';
                else
                    s = 'Diffusing';
                end
            else
                s = 'Transporting';
            end
            timedFprintf( 1, '%s %s (diffusion %.3g %.3g %s %s, mean absorption %.3g):\n', ...
                     s, ...
                     m.mgenIndexToName{i}, ...
                     sum(Dpar)/length(Dpar), ...
                     sum(Dper)/length(Dper), ...
                     s_iso, ...
                     s_unif, ...
                     mean(m.mgen_absorption(:,i)) );
            if diffusible || transportable
                if full3d
%         temperatures = diffusionFE( nodes, vxsets, m.FEsets(1), conductivity, ...
%             m.mgen_absorption(: i), m.mgen_production(:,i), m.morphogens(:,i), dt, fixednodes, ...
%             tolerance, tolerancemethod, maxtime, perturbation, [] );
                    newM = diffusionFE( ...
                        m.FEnodes, ...
                        m.FEsets(1).fevxs, ...
                        m.FEsets(1).fe, ...
                        m.conductivity(i).Dpar, ... % conductivity, ...  % TO BE FIXED to allow general conductivity tensors
                        m.mgen_absorption(:,i), ...
                        m.mgen_production(:,i), ...
                        m.morphogens(:,i), ...
                        ... % m.transportfield{i}, ... % transportvectors( m, i ), ...
                        m.globalProps.timestep, ...
                        fixedvxs, ...
                        m.globalProps.diffusiontolerance, ...
                        m.globalProps.solvertolerancemethod, ...
                        m.globalProps.maxsolvetime, ...
                        m.globalProps.perturbDiffusionEstimate, ...
                        m );
                else
                    nodes = m.nodes;
                    vxsets = m.tricellvxs;
                    newM = tempdiff( ...
                        nodes, ...
                        vxsets, ...
                        conductivity, ...
                        m.mgen_absorption(:,i), ...
                        m.mgen_production(:,i), ...
                        m.morphogens(:,i), ...
                        m.transportfield{i}, ... % transportvectors( m, i ), ...
                        m.globalProps.timestep, ...
                        fixedvxs, ...
                        m.cellareas, ...
                        m.unitcellnormals, ...
                        m.globalProps.diffusiontolerance, ...
                        m.globalProps.solvertolerancemethod, ...
                        m.globalProps.maxsolvetime, ...
                        m );
                end
%                 m.morphogens(m.morphogenclamp(:,i)==0,i) = ...
%                     newM(m.morphogenclamp(:,i)==0);
                m.morphogens(:,i) = m.morphogenclamp(:,i) .* m.morphogens(:,i) ...
                                    + (1 - m.morphogenclamp(:,i)) .* newM;
            end
        elseif all(m.mgen_absorption(:,i) <= 0)
            m.morphogens(~fixedmap,i) = m.morphogens(~fixedmap,i) + m.mgen_production(~fixedmap,i)*m.globalProps.timestep;
        elseif true
            if size(m.mgen_absorption,1)==1
                a = m.mgen_absorption(1,i) + zeros( sum(~fixedmap), 1 );
            else
                a = m.mgen_absorption(~fixedmap,i);
            end
            m.morphogens(~fixedmap,i) = productionAbsorption( ...
                m.morphogens(~fixedmap,i), ...
                m.mgen_production(~fixedmap,i), ...
                a, ...
                m.globalProps.timestep );
        end
    end
%     if false
%         for i=1:length(minM)
%             m.morphogens(:,i) = max(m.morphogens(:,i),minM(i));
%             m.morphogens(:,i) = min(m.morphogens(:,i),maxM(i));
%         end
%     end

    m.saved = 0;
    timedFprintf( 1, 'Completed.\n' );
end
