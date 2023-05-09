function printTubuleInteractionMethod( fid, m )
    if nargin==1
        m = fid;
        fid = 1;
    end
    fprintf( fid, 'Head growth rate %.4f micron/second.\n', getModelOption( m, 'plus_growthrate' ) );
    fprintf( fid, 'Tail shrink rate %.4f micron/second.\n', getModelOption( m, 'minus_shrinkrate' ) );
    fprintf( fid, 'Head cat rate %.4f micron/second.\n', getModelOption( m, 'plus_shrinkrate' ) );
    fprintf( fid, 'Tail cat rate %.4f micron/second.\n', getModelOption( m, 'minus_catshrinkrate' ) );
    fprintf( fid, 'Delay for crossover branch %.4f sec.\n', getModelOption( m, 'crossover_branch_delay' ) );
    fprintf( fid, 'Delay for crossover sever %.4f sec.\n', getModelOption( m, 'crossover_sever_delay' ) );
    fprintf( fid, 'Spontaneous cat rate %.4f per micron per second.\n', getModelOption( m, 'prob_plus_catastrophe' ) );
    fprintf( fid, 'Spontaneous branch rate %.4f per micron per second.\n', getModelOption( m, 'prob_branch_length_time_if' ) );
    tail_branch_rate = getModelOption( m, 'prob_tail_branch_time' );
    if isempty( tail_branch_rate )
        tail_branch_rate = 0;
    end
    fprintf( fid, 'Spontaneous tail branching rate %.4f per tubule per second.\n', tail_branch_rate );
    fprintf( fid, '    Branch forward prob %.4f, backwards prob %.4f.\n', ...
        m.tubules.tubuleparams.prob_branch_forwards, ...
        1 - m.tubules.tubuleparams.prob_branch_forwards ...
    );
    fprintf( fid, '    Branch parallel prob forward %.4f, backwards %.4f.\n', ...
        m.tubules.tubuleparams.prob_branch_parallel, ...
        m.tubules.tubuleparams.prob_branch_antiparallel );
    fprintf( fid, '    Branch forward mean %.4f, spread %.4f deg.\n', ...
        round( m.tubules.tubuleparams.branch_forwards_mean*(180/pi), 6 ), ...
        round( m.tubules.tubuleparams.branch_forwards_spread*(180/pi), 6 ) ...
    );
    fprintf( fid, '    Branch backward mean %.4f, spread %.4f deg.\n', ...
        round( m.tubules.tubuleparams.branch_backwards_mean*(180/pi), 6 ), ...
        round( m.tubules.tubuleparams.branch_backwards_spread*(180/pi), 6 ) ...
    );
    fprintf( fid, 'Spontaneous rescue rate %.4f per tubule per second.\n', getModelOption( m, 'prob_plus_rescue' ) );
    fprintf( fid, '    Rescue angle mean %.4f deg, std dev %.4f deg.\n', ...
        getModelOption( m, 'rescue_angle_mean' )*(180/pi), ...
        getModelOption( m, 'rescue_angle_spread' )*(180/pi) );
    fprintf( fid, 'Edge cat rate %.4f per event.\n', getModelOption( m, 'edge_plus_catastrophe_if' ) );
    
    fwrite( fid, newline() );
    
    fprintf( fid, 'Interaction method name %s.\n\n', getModelOption( m, 'collision_variant' ) );
    angles = m.tubules.tubuleparams.collision_angles;
    angles = round( angles * (180/pi), 6 );
    angles = [ 0, angles, 90 ];
    fprintf( fid, 'Outcome probabilities by angle of meeting:\n' );
    for i=1:(length(angles)-1)
        pzip = m.tubules.tubuleparams.probs_zip(i);
        pcat = m.tubules.tubuleparams.probs_cat(i);
        pcross = 1 - pzip - pcat;
        fprintf( fid, '%7.4f to %7.4f degrees:  zip %.4f  cat %.4f  cross %.4f  sum %.4f\n', ...
            angles(i), angles(i+1), pzip, pcat, pcross, pzip+ pcat+pcross );
    end
    
    fwrite( fid, newline() );
    
    pbranch = m.tubules.tubuleparams.prob_collide_branch;
    pcuteither = m.tubules.tubuleparams.prob_collide_cut;
    pnothing = 1 - pbranch - pcuteither;
    fprintf( fid, 'After crossover:  branch %.4f  cut either %.4f  nothing %.4f  sum %.4f\n', ...
        pbranch, pcuteither, pnothing, pbranch+pcuteither+pnothing );
    
    fwrite( fid, newline() );
    
    pcutself = m.tubules.tubuleparams.prob_collide_cut_collider;
    pcutother = 1 - pcutself;
    fprintf( fid, 'After crossover and cut:  cut self %.4f  cut other %.4f  sum %.4f\n', ...
        pcutself, pcutother, pcutself+pcutother );
    
    fwrite( fid, newline() );
    
    fprintf( fid, 'After a severing:\n    new head cat %.4f\n    new tail cat %.4f\n', ...
        m.tubules.tubuleparams.prob_collide_cut_headcat, ...
        m.tubules.tubuleparams.prob_collide_cut_tailcat );
end
