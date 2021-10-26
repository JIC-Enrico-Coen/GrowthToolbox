function m = applyMutations( m )
    fprintf( 1, 'applyMutations\n' );
    if m.allMutantEnabled
        for i=1:size(m.morphogens,2)
            m.morphogens(:,i) = m.morphogens(:,i) * m.mutantLevel(i);
        end
    end
end
