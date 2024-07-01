function angles = getMTLocalBranchingAngles( numangles, paramValues )

% IGNORE THESE COMMENTS. THEY'RE OUT OF DATE.
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
    
%     paramsNeeded = { 'prob_branch_forwards', ...
%                      'prob_branch_parallel', ...
%                      'prob_branch_antiparallel', ...
%                      'branch_forwards_mean', ...
%                      'branch_forwards_spread', ...
%                      'branch_backwards_mean', ...
%                      'branch_backwards_spread' };
    
    p_forwards = paramValues.prob_branch_forwards;
    p_par = paramValues.prob_branch_parallel;
    p_antipar = paramValues.prob_branch_antiparallel;
    mean_fwd = paramValues.branch_forwards_mean;
    spread_fwd = paramValues.branch_forwards_spread;
    mean_back = paramValues.branch_backwards_mean;
    spread_back = paramValues.branch_backwards_spread;

    angles = zeros( numangles, 1 );
    isfwd = rand(numangles,1) < p_forwards;
    ispar = isfwd & (rand(numangles,1) < p_par);
    isantipar = ~isfwd & (rand(numangles,1) < p_antipar);
    
    angles( ispar ) = 0;
    angles( isantipar ) = pi;
    
    isfwdspread = isfwd & ~ispar;
    angles( isfwdspread ) = randn(sum(isfwdspread),1) .* spread_fwd(isfwdspread) + mean_fwd(isfwdspread);
    angles( isfwdspread ) = modreflective( angles(isfwdspread), pi );
    
    isbackspread = ~isfwd & ~isantipar;
    angles( isbackspread ) = randn(sum(isbackspread),1) .* spread_back(isbackspread) + mean_back(isbackspread);
    angles( isbackspread ) = modreflective( angles(isbackspread), pi );
    angles( isbackspread ) = pi - angles( isbackspread );

    angles = angles .* randSign(numangles,1);
end
