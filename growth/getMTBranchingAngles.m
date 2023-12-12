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
    
    a = zeros(n,1);
    switch branchtype
        case 'free'
            forwards = rand(n,1) < m.tubules.tubuleparams.prob_branch_forwards;
            numFwd = sum(forwards);
            exact = false(n,1);
            exact(forwards) = rand(numFwd,1) < m.tubules.tubuleparams.prob_branch_parallel;
            exact(~forwards) = rand(n-numFwd,1) < m.tubules.tubuleparams.prob_branch_antiparallel;

            a = zeros(n,1);
            a(forwards & exact) = 0;
            a(~forwards & exact) = pi;

            fwdSpread = forwards & ~exact;
            a(fwdSpread) = randn(sum(fwdSpread),1) * m.tubules.tubuleparams.branch_forwards_spread + 40*(pi/180); % m.tubules.tubuleparams.branch_forwards_mean_faces; %%%%
            a(fwdSpread) = modreflective( a(fwdSpread), pi );

            backSpread = ~forwards & ~exact;
            a(backSpread) = randn(sum(backSpread),1) * m.tubules.tubuleparams.branch_backwards_spread + m.tubules.tubuleparams.branch_backwards_mean;
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
