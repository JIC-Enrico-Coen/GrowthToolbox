function a = getMTBranchingAngles( m, n, branchtype )
    % Prob of branching forwards: m.tubules.tubuleparams.prob_branch_forwards
    % If forwards, prob of being parallel: m.tubules.tubuleparams.prob_branch_parallel
    % If backwards, prob of being antiparallel: m.tubules.tubuleparams.prob_branch_antiparallel
    % If forwards and not parallel:
    %   mean angle: branch_forwards_mean
    %   std dev of angle: m.tubules.tubuleparams.prob_branch_forwards_spread
    % If backwards and not parallel:
    %   mean angle: branch_backwards_mean
    %   std dev of angle: m.tubules.tubuleparams.prob_branch_backwards_spread
    
    % The result is a value in the range 0..pi.
    
    % WARNING! This code will fail if the branching parameters vary
    % according to position or tubule identity. The code assumes that all
    % of the branching parameters are uniform across the mesh and across
    % all tubules. Currently (2024-02-08) the interaction function for the
    % tubules project in principle allows for branch_forwards_mean to take
    % a different value on the edge-regions and the faces. Actually setting
    % different values for these will result in errors. Fixing this problem
    % will require restructuring how we select locations to branch at.
    
    neededParams = { 'prob_branch_forwards', ...
              'prob_branch_parallel', ...
              'prob_branch_antiparallel', ...
              'branch_forwards_mean', ...
              'branch_forwards_spread', ...
              'branch_backwards_spread', ...
              'branch_backwards_mean' };
    paramValues = getTubuleParamsModifiedByMorphogens( m, neededParams );
    
    a = zeros(n,1);
    switch branchtype
        case 'free'
            forwards = rand(n,1) < paramValues.prob_branch_forwards;
            numFwd = sum(forwards);
            exact = false(n,1);
            exact(forwards) = rand(numFwd,1) < paramValues.prob_branch_parallel;
            exact(~forwards) = rand(n-numFwd,1) < paramValues.prob_branch_antiparallel;

            a = zeros(n,1);
            a(forwards & exact) = 0;
            a(~forwards & exact) = pi;

            fwdSpread = forwards & ~exact;
            a(fwdSpread) = randn(sum(fwdSpread),1) * paramValues.branch_forwards_spread + paramValues.branch_forwards_mean; % paramValues.branch_forwards_mean_faces; %%%%
            a(fwdSpread) = modreflective( a(fwdSpread), pi );

            backSpread = ~forwards & ~exact;
            a(backSpread) = randn(sum(backSpread),1) * paramValues.branch_backwards_spread + m.tubules.tubuleparams.branch_backwards_mean;
            a(backSpread) = modreflective( a(backSpread), pi );
            a(backSpread) = pi - a(backSpread);
            
        case 'crossover'
            % Uniform from 0 to +pi.
            a = rand(n,1) * pi;
            
        otherwise
            timedFprintf( 'Invalid branchtype %s.\n', branchtype );
    end
    
%     a = a .* randSign(n,1);
end
