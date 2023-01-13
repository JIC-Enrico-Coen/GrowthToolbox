function a = getMTBranchingAngles( m, n )
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
    
    forwards = rand(n,1) < m.tubules.tubuleparams.prob_branch_forwards;
    numFwd = sum(forwards);
    exact = false(n,1);
    exact(forwards) = rand(numFwd,1) < m.tubules.tubuleparams.prob_branch_parallel;
    exact(~forwards) = rand(n-numFwd,1) < m.tubules.tubuleparams.prob_branch_antiparallel;
    
    
    a = zeros(n,1);
    
    a(forwards & exact) = 0;
    
    a(~forwards & exact) = pi;
    
    fwdSpread = forwards & ~exact;
    a(fwdSpread) = randn(sum(fwdSpread),1) * m.tubules.tubuleparams.branch_forwards_spread + m.tubules.tubuleparams.branch_forwards_mean;
    a(fwdSpread) = min( max( a(fwdSpread), 0 ), pi );

    backSpread = ~forwards & ~exact;
    a(backSpread) = randn(sum(backSpread),1) * m.tubules.tubuleparams.branch_backwards_spread + m.tubules.tubuleparams.branch_backwards_mean;
    a(backSpread) = pi - min( max( a(backSpread), 0 ), pi );
end
