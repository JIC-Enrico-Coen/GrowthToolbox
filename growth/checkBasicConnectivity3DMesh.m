function [ok,errs] = checkBasicConnectivity3DMesh( m )
%[ok,errs] = checkBasicConnectivity3DMesh( m )
%   Check the consistency of m.FEsets.fevxs.  Passing this test is a
%   precondition for connectivity3D to function correctly.


    severity = 0;
    ok = true;
    errs = 0;
    numFEs = getNumberOfFEs( m );
    
    % Every vertex must be a member of at least one element.
    % Every element's vertexes must be listed in m.FEnodes.
    usedvxs = unique( sort( m.FEsets.fevxs(:) ) );
    unusedvxs = setdiff( 1:size(m.FEnodes,1), usedvxs );
    nonexistentvxs = setdiff( usedvxs, 1:size(m.FEnodes,1) );
    if ~isempty(unusedvxs)
        errs = errs+1;
        complain2( severity, '%d vertexes are not members of any element', length(unusedvxs) );
        unusedvxs
    end
    if ~isempty(nonexistentvxs)
        errs = errs+1;
        complain2( severity, '%d vertexes are members of an element but have no coordinates', length(nonexistentvxs) );
        nonexistentvxs'
    end


    % Each element must have distinct vertexes.
    sortedfevxs = sort( m.FEsets.fevxs, 2 );
    repeatedvxs = sortedfevxs(:,1:(end-1)) == sortedfevxs(:,2:end);
    badfevxs = any(repeatedvxs,2);
    if any(badfevxs)
        errs = errs+1;
        complain2( severity, '%d elements contain one or more repeated vertexes', sum(badfevxs) );
        badfevxs'
    end
    
    % No two elements can have the same vertexes.
    [sortedsortedfevxs,perm] = sortrows( sortedfevxs );
    duplicateFEs = all( sortedsortedfevxs(1:(end-1),:)==sortedsortedfevxs(2:end,:), 2 );
    if any( duplicateFEs )
        errs = errs+1;
        complain2( severity, 'At least %d elements have identical vertexes', sum(duplicateFEs) );
        perm( [duplicateFEs;false] | [false;duplicateFEs] )
    end
    
    
    % No three elements can share three vertexes.
    [alltriples,perm] = sortrows( reshape( sortedfevxs( :, [1 2 3 1 2 4 1 3 4 2 3 4] )', 3, 4*numFEs )' );
    duplicates = all( alltriples(1:(end-1),:)==alltriples(2:end,:), 2 );
    [starts,ends] = runends( duplicates );
    badstarts = starts(duplicates(starts));
    badends = ends(duplicates(starts));
    runlengths = badends-badstarts;
    if any(runlengths >= 2)
        errs = errs+1;
        complain2( severity, '%d faces belong to three or more elements', sum(runlengths >= 2) );
    end
    
    
    ok = errs==0;
end

